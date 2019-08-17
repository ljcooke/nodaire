# frozen_string_literal: true

require 'nodaire'

describe Nodaire::Tablatal::Parser do
  let(:input) do
    <<~TBTL
      NAME    AGE   COLOR
      Erica   12    Opal
      Alex    23    Cyan, Turquoise
      Nike    34    赤い
      Ruca    45    Grey
    TBTL
  end

  let(:expected_data) do
    [
      { name: 'Erica', age: '12', color: 'Opal' },
      { name: 'Alex',  age: '23', color: 'Cyan, Turquoise' },
      { name: 'Nike',  age: '34', color: '赤い' },
      { name: 'Ruca',  age: '45', color: 'Grey' },
    ]
  end

  let(:expected_keys) { %i[name age color] }

  let(:result) { described_class.new(input, false, options) }
  let(:strict_result) { described_class.new(input, true, options) }
  let(:options) do
    {}
  end

  shared_examples :valid_input do
    it 'returns the expected result' do
      expect(result.data).to eq expected_data
      expect(result.keys).to eq expected_keys
      expect(strict_result.data).to eq expected_data
      expect(strict_result.keys).to eq expected_keys
    end

    it 'does not have errors' do
      expect(result.errors).to be_empty
      expect(strict_result.errors).to be_empty
    end
  end

  shared_examples :invalid_input do
    it 'returns the expected result' do
      expect(result.data).to eq expected_data
      expect(result.keys).to eq expected_keys
    end

    it 'has errors' do
      expect(result.errors).not_to be_empty
    end

    it 'raises a parser error in strict mode' do
      expect { strict_result }.to raise_error Nodaire::Tablatal::ParserError
    end
  end

  include_examples :valid_input

  describe 'preserve_keys' do
    context 'when true' do
      let(:options) do
        { preserve_keys: true }
      end

      let(:expected_data) do
        [
          { 'NAME' => 'Erica', 'AGE' => '12', 'COLOR' => 'Opal' },
          { 'NAME' => 'Alex',  'AGE' => '23', 'COLOR' => 'Cyan, Turquoise' },
          { 'NAME' => 'Nike',  'AGE' => '34', 'COLOR' => '赤い' },
          { 'NAME' => 'Ruca',  'AGE' => '45', 'COLOR' => 'Grey' },
        ]
      end

      let(:expected_keys) { %w[NAME AGE COLOR] }

      include_examples :valid_input
    end
  end

  context 'with no input' do
    let(:input) { nil }
    let(:expected_data) { [] }
    let(:expected_keys) { [] }

    include_examples :valid_input
  end

  context 'with only whitespace' do
    let(:input) { '    ' }
    let(:expected_data) { [] }
    let(:expected_keys) { [] }

    include_examples :valid_input
  end

  context 'with one line' do
    let(:input) { 'NAME    AGE   COLOR' }
    let(:expected_data) { [] }
    let(:expected_keys) { %i[name age color] }

    include_examples :valid_input
  end

  context 'with leading whitespace' do
    let(:input) do
      <<~TBTL
         NAME   AGE   COLOR
        Erica   12    Opal
        Alex    23    Cyan, Turquoise
        Nike    34    赤い
        Ruca    45    Grey
      TBTL
    end

    include_examples :valid_input
  end

  context 'with trailing spaces' do
    let(:input) do
      <<~TBTL
        NAME    AGE   COLOR#{' '}
        Erica   12    Opal
        Alex    23    Cyan, Turquoise\t\t
        Nike    34    赤い
        Ruca    45    Grey#{' '}
      TBTL
    end

    include_examples :valid_input
  end

  context 'with misaligned entries' do
    context 'shifted left' do
      let(:input) do
        <<~TBTL
          NAME    AGE   COLOR
          Erica   12   Opal
          Alex    23    Cyan, Turquoise
          Nike    34    赤い
          Ruca    45    Grey
        TBTL
      end

      let(:expected_data) do
        [
          { name: 'Erica', age: '12   O', color: 'pal' },
          { name: 'Alex',  age: '23', color: 'Cyan, Turquoise' },
          { name: 'Nike',  age: '34', color: '赤い' },
          { name: 'Ruca',  age: '45', color: 'Grey' },
        ]
      end

      include_examples :valid_input
    end

    context 'shifted right (staying within the column width)' do
      let(:input) do
        <<~TBTL
          NAME    AGE   COLOR
          Erica   12    Opal
           Alex    23   \tCyan, Turquoise
          Nike    34     赤い
           Ruca    45   Grey
        TBTL
      end

      include_examples :valid_input
    end
  end

  context 'with entries filling the column width' do
    let(:input) do
      <<~TBTL
        NAME AGE   COLOR
        Erica12    Opal
        Alex 23    Cyan, Turquoise
        Nike 34    赤い
        Ruca 45    Grey
      TBTL
    end

    include_examples :valid_input
  end

  context 'with incomplete lines' do
    let(:input) do
      <<~TBTL
        NAME    AGE   COLOR
        Erica   12    Opal
        Alex    23
        Nike    34    赤い
        Ruca
      TBTL
    end

    let(:expected_data) do
      [
        { name: 'Erica', age: '12', color: 'Opal' },
        { name: 'Alex',  age: '23', color: '' },
        { name: 'Nike',  age: '34', color: '赤い' },
        { name: 'Ruca',  age: '',   color: '' },
      ]
    end

    include_examples :valid_input
  end

  context 'with duplicate keys' do
    let(:input) do
      <<~TBTL
        NAME    AGE   NAME       COLOR
        Erica   12    Duplicate  Opal
        Alex    23    Duplicate  Cyan, Turquoise
        Nike    34    Duplicate  赤い
        Ruca    45    Duplicate  Grey
      TBTL
    end

    include_examples :invalid_input
  end
end
