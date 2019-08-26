# frozen_string_literal: true

require 'nodaire/tablatal'

describe Nodaire::Tablatal do
  examples = ExampleReader.new

  let(:input)           { examples['tablatal_valid.tbtl'] }
  let(:expected_output) { examples['tablatal_valid.json'] }

  let(:instance) { described_class.parse(input) }
  let(:input_with_spaces) { input.gsub("\n", " \t \n") }

  describe 'example files' do
    shared_examples 'the input is parsed correctly' do
      it 'matches the expected output' do
        expect(instance.to_a).to eq expected_output
      end

      context 'with trailing spaces' do
        let(:instance) { described_class.parse(input_with_spaces) }

        it 'matches the expected output' do
          expect(instance.to_a).to eq expected_output
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

    describe 'example with errors' do
      let(:input)           { examples['tablatal_invalid.tbtl'] }
      let(:expected_output) { examples['tablatal_invalid.json'] }

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
        let(:input) { 'INVALID INVALID' }

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
        let(:input) { 'INVALID INVALID' }

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

    describe '#to_a' do
      it 'returns the expected output' do
        expect(instance.to_a).to eq expected_output
      end
    end

    describe '#keys' do
      it 'returns the keys in the original order' do
        expect(instance.keys).to eq %w[NAME AGE COLOR]
      end

      context 'with symbolize_names' do
        let(:symbolize_names) { true }

        it 'converts the keys to lowercase symbols' do
          expect(instance.keys).to eq %i[name age color]
        end
      end
    end

    describe '#errors' do
      it 'returns an empty array' do
        expect(instance.errors).to eq []
      end

      context 'with invalid input' do
        let(:input) { 'INVALID INVALID' }

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
        let(:input) { 'INVALID INVALID' }

        it 'returns false' do
          expect(instance.valid?).to be false
        end
      end
    end

    describe '#[]' do
      let(:index) { 0 }

      context 'with an index in range' do
        it 'returns the data for the given row index' do
          expect(instance[index]).to eq expected_output[index]
        end
      end

      context 'with an index outside the range' do
        let(:index) { 100 }

        it 'returns nil' do
          expect(instance[index]).to be_nil
        end
      end

      context 'when attempting assignment' do
        it 'raises an exception' do
          expect { instance[index] = {} }.to raise_error NoMethodError
        end
      end
    end

    describe '#to_csv' do
      let(:expected_output) { examples['tablatal_valid.csv'] }

      it 'returns a CSV string' do
        expect(instance.to_csv).to eq expected_output
      end
    end

    describe '#to_json' do
      let(:parsed_json) { JSON.parse(instance.to_json) }

      it 'returns a JSON array string' do
        expect(parsed_json).to eq expected_output
      end
    end
  end

  describe 'Enumerable' do
    it 'implements the Enumerable mixin' do
      expect(instance).to respond_to :each
    end

    it 'yields the output rows' do
      expect(instance.map.to_a).to eq expected_output
    end
  end
end
