# frozen_string_literal: true

require 'nodaire'

describe Nodaire::Indental::Parser do
  let(:input) do
    <<~NDTL
      NAME
        KEY : VALUE
        LIST
          ITEM 1
          ITEM 2
    NDTL
  end

  let(:expected_data) do
    {
      name: {
        key: 'VALUE',
        list: ['ITEM 1', 'ITEM 2'],
      },
    }
  end

  let(:complete_example_input) do
    <<~NDTL
      NAME
        KEY : VALUE
        LIST
          ITEM 1
          ITEM 2

      ; love 2 shop
      Shopping list
        Last updated : 2019-08-17 19:00
        Groceries
          Milk
          Bread
          Baby spinach

      Allowed duplicates
        List
          Duplicate
          Duplicate

      Empty category

      Category with empty keys and lists
        Empty key : [This isn't supported yet!]
        Empty list

      Extra  \t  space  \t
        Key  \t  1  \t  :  \t  Value  \t  1  \t
        Key  \t  2  \t  :  \t  Value  \t  2  \t

      Comments are not recognised on data lines ; !
        Key : Value                             ; !
        List                                    ; !
          Item 1                                ; !
          Item 2                                ; !

      Unicode \u{1f60e}
        \u{1f32f} : \u{1f5a4}
    NDTL
  end

  let(:complete_example_expected_data) do
    {
      name: {
        key: 'VALUE',
        list: ['ITEM 1', 'ITEM 2'],
      },
      shopping_list: {
        last_updated: '2019-08-17 19:00',
        groceries: [
          'Milk',
          'Bread',
          'Baby spinach',
        ],
      },
      allowed_duplicates: {
        list: [
          'Duplicate',
          'Duplicate',
        ],
      },
      empty_category: {},
      category_with_empty_keys_and_lists: {
        empty_key: "[This isn't supported yet!]",
        empty_list: [],
      },
      extra_space: {
        key_1: "Value  \t  1",
        key_2: "Value  \t  2",
      },
      'comments_are_not_recognised_on_data_lines_;_!': {
        key: 'Value                             ; !',
        'list_;_!': [
          'Item 1                                ; !',
          'Item 2                                ; !',
        ],
      },
      'unicode_😎': {
        '🌯': '🖤',
      },
    }
  end

  let(:result) { described_class.new(input, false, options) }
  let(:strict_result) { described_class.new(input, true, options) }
  let(:options) { Hash.new }

  shared_examples :valid_input do
    it 'returns the expected result' do
      expect(result.data).to eq expected_data
      expect(strict_result.data).to eq expected_data
    end

    it 'does not have errors' do
      expect(result.errors).to be_empty
      expect(strict_result.errors).to be_empty
    end
  end

  shared_examples :invalid_input do
    it 'returns the expected result' do
      expect(result.data).to eq expected_data
    end

    it 'has errors' do
      expect(result.errors).not_to be_empty
    end

    it 'raises a parser error in strict mode' do
      expect { strict_result }.to raise_error Nodaire::Indental::ParserError
    end
  end

  include_examples :valid_input

  context 'with a fully featured example' do
    let(:input) { complete_example_input }
    let(:expected_data) { complete_example_expected_data }

    include_examples :valid_input
  end

  describe 'preserve_keys' do
    context 'when true' do
      let(:options) do
        { preserve_keys: true }
      end

      let(:input) do
        <<~NDTL
          NAME 1
            KEY 1 : VALUE
            LIST 1
              ITEM 1
              ITEM 2
        NDTL
      end

      let(:expected_data) do
        {
          'NAME 1' => {
            'KEY 1' => 'VALUE',
            'LIST 1' => ['ITEM 1', 'ITEM 2'],
          },
        }
      end

      include_examples :valid_input
    end
  end

  context 'with no input' do
    let(:input) { nil }
    let(:expected_data) do
      {}
    end

    include_examples :valid_input
  end

  context 'with only whitespace' do
    let(:input) { '    ' }
    let(:expected_data) do
      {}
    end

    include_examples :valid_input
  end

  context 'with a JavaScript template string wrapper' do
    let(:input) do
      <<~NDTL
        example = `
        NAME
          KEY : VALUE
          LIST
            ITEM 1
            ITEM 2
        `
      NDTL
    end

    include_examples :valid_input
  end

  context 'with odd-numbered indentation' do
    let(:input) do
      <<~NDTL
        NAME
          KEY : VALUE
           OOPS : INVALID
          LIST
            ITEM 1
            ITEM 2
      NDTL
    end

    include_examples :invalid_input
  end

  context 'with greater than 4 spaces of indentation' do
    let(:input) do
      <<~NDTL
        NAME
          KEY : VALUE
          LIST
            ITEM 1
              INVALID
            ITEM 2
      NDTL
    end

    include_examples :invalid_input
  end

  context 'with indented lines before the first category' do
    let(:input) do
      <<~NDTL
          INVALID
        NAME
          KEY : VALUE
          LIST
            ITEM 1
            ITEM 2
      NDTL
    end

    include_examples :invalid_input
  end

  context 'with indented list items before a list line' do
    let(:input) do
      <<~NDTL
        NAME
          KEY : VALUE
            INVALID
          LIST
            ITEM 1
            ITEM 2
      NDTL
    end

    include_examples :invalid_input
  end

  context 'with duplicate categories' do
    let(:input) do
      <<~NDTL
        NAME
          KEY : VALUE
        NAME
          KEY : DUPLICATE
        OTHER
          KEY : VALUE
      NDTL
    end

    let(:expected_data) do
      {
        name: {
          key: 'VALUE',
        },
        other: {
          key: 'VALUE',
        },
      }
    end

    include_examples :invalid_input
  end

  context 'with duplicate keys' do
    let(:input) do
      <<~NDTL
        NAME
          KEY : VALUE
          KEY : DUPLICATE
          KEY
            DUPLICATE
          OTHER : VALUE
      NDTL
    end

    let(:expected_data) do
      {
        name: {
          key: 'VALUE',
          other: 'VALUE',
        },
      }
    end

    include_examples :invalid_input
  end

  context 'with duplicate list names' do
    let(:input) do
      <<~NDTL
        NAME
          LIST
            ITEM
          LIST
            DUPLICATE
          LIST : DUPLICATE
          OTHER
            ITEM
        OTHER
          LIST
            OTHER
      NDTL
    end

    let(:expected_data) do
      {
        name: {
          list: ['ITEM'],
          other: ['ITEM'],
        },
        other: {
          list: ['OTHER'],
        }
      }
    end

    include_examples :invalid_input
  end
end
