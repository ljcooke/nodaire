# frozen_string_literal: true

require 'nodaire/indental'

describe Nodaire::Indental do
  examples = ExampleReader.new

  let(:input)           { examples['indental_valid_basic.ndtl'] }
  let(:expected_output) { examples['indental_valid_basic.json'] }

  let(:instance) { described_class.parse(input) }
  let(:input_with_spaces) { input.gsub("\n", " \t \n") }

  describe 'example files' do
    shared_examples 'the input is parsed correctly' do
      it 'matches the expected output' do
        expect(instance.to_h).to eq expected_output
      end

      context 'with trailing spaces' do
        let(:instance) { described_class.parse(input_with_spaces) }

        it 'matches the expected output' do
          expect(instance.to_h).to eq expected_output
        end
      end
    end

    shared_examples 'the input is valid' do
      it 'is valid' do
        expect(instance).to be_valid
      end

      context 'with trailing spaces' do
        let(:instance) { described_class.parse(input_with_spaces) }

        it 'is valid' do
          expect(instance).to be_valid
        end
      end
    end

    shared_examples 'the input is invalid' do
      it 'is invalid' do
        expect(instance).not_to be_valid
      end

      it 'has errors' do
        expect(instance.errors).not_to be_empty
      end
    end

    describe 'basic example' do
      it_behaves_like 'the input is parsed correctly'
      it_behaves_like 'the input is valid'
    end

    describe 'more complete valid example' do
      let(:input)           { examples['indental_valid_full.ndtl'] }
      let(:expected_output) { examples['indental_valid_full.json'] }

      it_behaves_like 'the input is parsed correctly'
      it_behaves_like 'the input is valid'
    end

    describe 'example with errors' do
      let(:input)           { examples['indental_invalid.ndtl'] }
      let(:expected_output) { examples['indental_invalid.json'] }

      it_behaves_like 'the input is parsed correctly'
      it_behaves_like 'the input is invalid'
    end
  end

  describe 'class methods' do
    describe '.parse' do
      let(:output) { described_class.parse(input) }

      it 'returns an instance of the class' do
        expect(output).to be_a described_class
      end

      context 'with invalid input' do
        let(:input) { "\tINVALID" }

        it 'returns an instance of the class' do
          expect(output).to be_a described_class
        end
      end
    end

    describe '.parse!' do
      let(:output) { described_class.parse!(input) }

      it 'returns an instance of the class' do
        expect(output).to be_a described_class
      end

      context 'with invalid input' do
        let(:input) { "\tINVALID" }

        it 'raises a parser error' do
          expect { output }.to raise_error Nodaire::ParserError
        end
      end
    end
  end

  describe 'instance methods' do
    let(:symbolize_names) { false }
    let(:instance) do
      described_class.parse(input, symbolize_names: symbolize_names)
    end

    describe '#to_h' do
      it 'returns the expected output' do
        expect(instance.to_h).to eq expected_output
      end
    end

    describe '#categories' do
      let(:input) do
        <<~NDTL
          NAME
            KEY : VALUE
            LIST
              ITEM1
              ITEM2
          ABC
          XYZ
        NDTL
      end

      it 'returns the category names in the original order' do
        expect(instance.categories).to eq %w[NAME ABC XYZ]
      end

      context 'with symbolize_names' do
        let(:symbolize_names) { true }

        it 'converts the category names to lowercase symbols' do
          expect(instance.categories).to eq %i[name abc xyz]
        end
      end
    end

    describe '#errors' do
      it 'returns an empty array' do
        expect(instance.errors).to eq []
      end

      context 'with invalid input' do
        let(:input) { "\tINVALID" }

        it 'returns an array of error strings' do
          expect(instance.errors.size).to eq 1
          expect(instance.errors.last).to be_a String
        end

        it 'includes the line number in each error message' do
          expect(instance.errors.last).to match(/\b(on line 1)\b/)
        end
      end
    end

    describe '#valid?' do
      it 'returns true' do
        expect(instance.valid?).to be true
      end

      context 'with invalid input' do
        let(:input) { "\tINVALID" }

        it 'returns false' do
          expect(instance.valid?).to be false
        end
      end
    end

    describe '#[]' do
      let(:category) { 'NAME' }

      context 'with an existing category name' do
        it 'returns the category data' do
          expect(instance[category]).to eq expected_output[category]
        end
      end

      context 'with a nonexistent category name' do
        let(:category) { 'NONE' }

        it 'returns nil' do
          expect(instance[category]).to be_nil
        end
      end

      context 'when attempting assignment' do
        it 'raises an exception' do
          expect { instance[category] = {} }.to raise_error NoMethodError
        end
      end
    end

    describe '#to_json' do
      let(:possible_outputs) do
        [
          '{"NAME":{"KEY":"VALUE","LIST":["ITEM 1","ITEM 2"]}}',
          '{"NAME":{"LIST":["ITEM 1","ITEM 2"],"KEY":"VALUE"}}',
        ]
      end

      it 'returns a JSON string' do
        output = instance.to_json
        expect(output).to be_a String
        expect(possible_outputs).to include(output)
      end
    end
  end

  describe 'Enumerable' do
    it 'implements the Enumerable mixin' do
      expect(instance).to respond_to :each
    end

    it 'yields pairs of category name and category data' do
      expect(instance.map.to_a).to eq expected_output.to_a
    end
  end
end
