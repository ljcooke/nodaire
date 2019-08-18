# frozen_string_literal: true

require 'nodaire/indental'

describe Nodaire::Indental do
  let(:input) do
    <<~NDTL
      NAME
        KEY : VALUE
        LIST
          ITEM1
          ITEM2
    NDTL
  end

  let(:expected_output) do
    {
      'NAME' => {
        'KEY' => 'VALUE',
        'LIST' => %w[ITEM1 ITEM2],
      },
    }
  end

  describe 'class methods' do
    describe '.parse' do
      let(:return_value) { described_class.parse(input) }

      it 'returns an instance of the class' do
        expect(return_value).to be_a described_class
      end

      context 'with invalid input' do
        let(:input) { "\tINVALID" }

        it 'returns an instance of the class' do
          expect(return_value).to be_a described_class
        end
      end
    end

    describe '.parse!' do
      let(:return_value) { described_class.parse!(input) }

      it 'returns an instance of the class' do
        expect(return_value).to be_a described_class
      end

      context 'with invalid input' do
        let(:input) { "\tINVALID" }

        it 'raises a parser error' do
          expect { return_value }.to raise_error Nodaire::Indental::ParserError
        end
      end
    end
  end

  describe 'instance methods' do
    let(:instance) { described_class.parse(input) }

    describe '#data' do
      it 'returns the expected output' do
        expect(instance.data).to eq expected_output
      end
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

      it 'returns the expected output' do
        expect(instance.categories).to eq %w[ABC NAME XYZ]
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

    describe '#to_json' do
      let(:possible_outputs) do
        [
          '{"NAME":{"KEY":"VALUE","LIST":["ITEM1","ITEM2"]}}',
          '{"NAME":{"LIST":["ITEM1","ITEM2"],"KEY":"VALUE"}}',
        ]
      end

      it 'returns the expected output' do
        output = instance.to_json
        expect(output).to be_a String
        expect(possible_outputs).to include(output)
      end
    end
  end
end
