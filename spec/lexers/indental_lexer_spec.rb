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
    let(:token) { described_class.token_for_line(input, 1) }

    context 'with a category line' do
      let(:input) { "Some \t category\t" }

      it 'returns a category token' do
        expect(token.type).to eq :category
        expect(token.key).to eq 'Some category'
        expect(token.value).to be_nil
      end
    end

    context 'with a key-value line' do
      let(:input) { "  Some  key : Some \t value\t" }

      it 'returns a key-value token' do
        expect(token.type).to eq :key_value
        expect(token.key).to eq 'Some key'
        expect(token.value).to eq 'Some value'
      end
    end

    context 'with a list name line' do
      let(:input) { "  List \t name\t" }

      it 'returns a list name token' do
        expect(token.type).to eq :list_name
        expect(token.key).to eq 'List name'
        expect(token.value).to be_nil
      end
    end

    context 'with a list item line' do
      let(:input) { "    List \t  item " }

      it 'returns a list item token' do
        expect(token.type).to eq :list_item
        expect(token.key).to be_nil
        expect(token.value).to eq 'List item'
      end
    end

    context 'with an unexpected indent' do
      let(:input) { ' ' * 6 }

      it 'returns an error token' do
        expect(token.type).to eq :error
        expect(token.key).to be_nil
        expect(token.value).not_to be_nil
        expect(token.value.downcase).to match(/indent/)
      end
    end

    context 'indented with tabs' do
      let(:input) { "\tKEY : VALUE" }

      it 'returns an error token' do
        expect(token.type).to eq :error
        expect(token.key).to be_nil
        expect(token.value).not_to be_nil
        expect(token.value.downcase).to match(/indent/)
      end
    end
  end
end
