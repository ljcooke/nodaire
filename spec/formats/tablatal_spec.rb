# frozen_string_literal: true

require 'nodaire'

describe Nodaire::Tablatal do
  let(:instance) { described_class.parse(input) }

  let(:input) do
    <<~TBTL
      NAME    AGE   COLOR
      Erica   12    Opal
      Alex    23    Cyan, Turquoise
      Nike    34    赤い
      Ruca    45    Grey
    TBTL
  end

  let(:expected_output) do
    [
      { name: 'Erica', age: '12', color: 'Opal' },
      { name: 'Alex',  age: '23', color: 'Cyan, Turquoise' },
      { name: 'Nike',  age: '34', color: '赤い' },
      { name: 'Ruca',  age: '45', color: 'Grey' },
    ]
  end

  describe '.parse' do
    let(:result) { described_class.parse(input) }

    it 'returns an instance of the class' do
      expect(result).to be_a described_class
    end
  end

  describe '#rows' do
    it 'returns the expected output' do
      expect(instance.rows).to eq expected_output
    end
  end

  describe '#to_a' do
    it 'returns the expected output' do
      expect(instance.to_a).to eq expected_output
    end
  end

  describe '#keys' do
    it 'returns the keys in the original order' do
      expect(instance.keys).to eq %i[name age color]
    end
  end

  describe '#to_csv' do
    let(:expected_output) do
      <<~CSV
        name,age,color
        Erica,12,Opal
        Alex,23,"Cyan, Turquoise"
        Nike,34,赤い
        Ruca,45,Grey
      CSV
    end

    it 'returns the expected output' do
      expect(instance.to_csv).to eq expected_output
    end
  end
end
