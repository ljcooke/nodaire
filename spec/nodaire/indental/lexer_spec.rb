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

    shared_examples 'the type is set correctly' do
      it 'returns a token with the expected type' do
        expect(token.type).to eq expected_type
      end
    end

    shared_examples 'the key is set correctly' do
      it 'returns a token with the expected key' do
        expect(token.key).to eq expected_key
      end
    end

    shared_examples 'the value is set correctly' do
      it 'returns a token with the expected value' do
        expect(token.value).to eq expected_value
      end
    end

    context 'with a category line' do
      let(:input) { "Some \t category\t" }

      let(:expected_type) { :category }
      let(:expected_key) { 'Some category' }
      let(:expected_value) { nil }

      it_behaves_like 'the type is set correctly'
      it_behaves_like 'the key is set correctly'
      it_behaves_like 'the value is set correctly'
    end

    context 'with a key-value line' do
      let(:input) { "  Some  key : Some \t value\t" }

      let(:expected_type) { :key_value }
      let(:expected_key) { 'Some key' }
      let(:expected_value) { 'Some value' }

      it_behaves_like 'the type is set correctly'
      it_behaves_like 'the key is set correctly'
      it_behaves_like 'the value is set correctly'

      context 'with an empty key' do
        let(:input) { '  Some key :' }

        let(:expected_value) { '' }

        it_behaves_like 'the type is set correctly'
        it_behaves_like 'the key is set correctly'
        it_behaves_like 'the value is set correctly'
      end

      context 'with the separators appearing more than once' do
        let(:input) { '  Some key : value : other' }

        it_behaves_like 'the type is set correctly'
        it_behaves_like 'the key is set correctly'

        it 'sets everything after the first separator as the value' do
          expect(token.value).to eq 'value : other'
        end
      end
    end

    context 'with a list name line' do
      let(:input) { "  List \t name\t" }

      let(:expected_type) { :list_name }
      let(:expected_key) { 'List name' }
      let(:expected_value) { nil }

      it_behaves_like 'the type is set correctly'
      it_behaves_like 'the key is set correctly'
      it_behaves_like 'the value is set correctly'

      context 'when a key-value line is missing a space before the separator' do
        let(:input) { '  Some key: Some value' }

        it 'returns a list name token' do
          expect(token.type).to eq :list_name
        end

        it 'sets the entire line as the list name' do
          expect(token.key).to eq 'Some key: Some value'
        end

        it 'does not set a value' do
          expect(token.value).to be_nil
        end
      end
    end

    context 'with a list item line' do
      let(:input) { "    List \t  item " }

      let(:expected_type) { :list_item }
      let(:expected_key) { nil }
      let(:expected_value) { 'List item' }

      it_behaves_like 'the type is set correctly'
      it_behaves_like 'the key is set correctly'
      it_behaves_like 'the value is set correctly'
    end

    context 'with an unexpected indent' do
      let(:input) { ' ' * 6 }

      let(:expected_type) { :error }
      let(:expected_key) { nil }

      it_behaves_like 'the type is set correctly'
      it_behaves_like 'the key is set correctly'

      it 'sets an error message about indentation' do
        expect(token.value.downcase).to match(/indent/)
      end
    end

    context 'when indented with tabs' do
      let(:input) { "\tKEY : VALUE" }

      let(:expected_type) { :error }
      let(:expected_key) { nil }

      it_behaves_like 'the type is set correctly'
      it_behaves_like 'the key is set correctly'

      it 'sets an error message about indentation' do
        expect(token.value.downcase).to match(/indent/)
      end
    end
  end
end
