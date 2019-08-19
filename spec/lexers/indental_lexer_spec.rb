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
          CATEGORY
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
      let(:input) { "SOME \t CATEGORY\t" }

      it 'returns a category token' do
        expect(output.type).to eq :category
        expect(output.values).to eq ['SOME CATEGORY']
        expect(output.symbol).to eq :some_category
      end
    end

    context 'with a key-value line' do
      let(:input) { "  SOME  KEY : SOME \t VALUE\t" }

      it 'returns a key-value token' do
        expect(output.type).to eq :key_value
        expect(output.values).to eq ['SOME KEY', 'SOME VALUE']
        expect(output.symbol).to eq :some_key
      end
    end

    context 'with a list name line' do
      let(:input) { "  LIST \t NAME\t" }

      it 'returns a list name token' do
        expect(output.type).to eq :list_name
        expect(output.values).to eq ['LIST NAME']
        expect(output.symbol).to eq :list_name
      end
    end

    context 'with a list item line' do
      let(:input) { "    LIST \t  ITEM " }

      it 'returns a list item token' do
        expect(output.type).to eq :list_item
        expect(output.values).to eq ['LIST ITEM']
        expect(output.symbol).to be_nil
      end
    end

    context 'with an unexpected indent' do
      let(:input) { ' ' * 6 }

      it 'returns an error token' do
        expect(output.type).to eq :error
        expect(output.values).not_to be_empty
      end
    end
  end
end
