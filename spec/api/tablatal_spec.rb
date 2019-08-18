# frozen_string_literal: true

require 'nodaire/tablatal'

describe Nodaire::Tablatal do
  let(:input) do
    <<~TBTL
      NAME    AGE   COLOR
      Erica   12    Opal
      Alex    23    Cyan
      Nike    34    Red
      Ruca    45    Grey
    TBTL
  end

  let(:expected_output) do
    [
      { 'NAME' => 'Erica', 'AGE' => '12', 'COLOR' => 'Opal' },
      { 'NAME' => 'Alex',  'AGE' => '23', 'COLOR' => 'Cyan' },
      { 'NAME' => 'Nike',  'AGE' => '34', 'COLOR' => 'Red' },
      { 'NAME' => 'Ruca',  'AGE' => '45', 'COLOR' => 'Grey' },
    ]
  end

  describe 'class methods' do
    describe '.parse' do
      let(:return_value) { described_class.parse(input) }

      it 'returns an instance of the class' do
        expect(return_value).to be_a described_class
      end

      context 'with invalid input' do
        let(:input) { 'INVALID INVALID' }

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
        let(:input) { 'INVALID INVALID' }

        it 'raises a parser error' do
          expect { return_value }.to raise_error Nodaire::ParserError
        end
      end
    end
  end

  describe 'instance methods' do
    let(:symbolize_names) { false }
    let(:instance) do
      described_class.parse(input, symbolize_names: symbolize_names)
    end

    describe '#data' do
      it 'returns the expected output' do
        expect(instance.data).to eq expected_output
      end
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

    describe '#to_csv' do
      let(:input) do
        <<~TBTL
          NAME    AGE   COLOR
          Erica   12    Opal
          Alex    23    Cyan, Turquoise
          Nike    34    Red
          Ruca    45    Grey
        TBTL
      end

      let(:expected_output) do
        <<~CSV
          NAME,AGE,COLOR
          Erica,12,Opal
          Alex,23,"Cyan, Turquoise"
          Nike,34,Red
          Ruca,45,Grey
        CSV
      end

      it 'returns the expected output' do
        expect(instance.to_csv).to eq expected_output
      end
    end
  end
end
