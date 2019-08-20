# frozen_string_literal: true

require 'nodaire'

describe Nodaire::Indental::Lexer do
  describe '.tokenize' do
    let(:output) { described_class.tokenize(input) }

    context 'with no input' do
      let(:input) { nil }

      it 'returns an empty array' do
        expect(output).to eq []
      end
    end

    context 'with an indental document' do
      let(:input) do
        <<~NDTL
          category
            ; comment
            KEY : VALUE

            LIST
              ITEM 1
              ITEM 2
        NDTL
      end

      it 'returns tokens with the expected types' do
        expect(output.map(&:type)).to eq %i[
          category
          key_value
          list_name
          list_item
          list_item
        ]
      end

      it 'records the correct line numbers' do
        expect(output.map(&:line_num)).to eq [1, 3, 5, 6, 7]
      end
    end
  end

  describe '.token_for_line' do
    let(:output) { described_class.token_for_line(input, 1) }

    context 'with a category line' do
      let(:input) { "Some \t category\t" }

      it 'returns a category token' do
        expect(output.type).to eq :category
        expect(output.key).to eq 'Some category'
        expect(output.value).to be_nil
      end
    end

    context 'with a key-value line' do
      let(:input) { "  Some  key : Some \t value\t" }

      it 'returns a key-value token' do
        expect(output.type).to eq :key_value
        expect(output.key).to eq 'Some key'
        expect(output.value).to eq 'Some value'
      end
    end

    context 'with a list name line' do
      let(:input) { "  List \t name\t" }

      it 'returns a list name token' do
        expect(output.type).to eq :list_name
        expect(output.key).to eq 'List name'
        expect(output.value).to be_nil
      end
    end

    context 'with a list item line' do
      let(:input) { "    List \t  item " }

      it 'returns a list item token' do
        expect(output.type).to eq :list_item
        expect(output.key).to be_nil
        expect(output.value).to eq 'List item'
      end
    end

    context 'with an unexpected indent' do
      let(:input) { ' ' * 6 }

      it 'returns an error token' do
        expect(output.type).to eq :error
        expect(output.key).to be_nil
        expect(output.value).not_to be_empty
      end
    end
  end
end
