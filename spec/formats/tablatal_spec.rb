# frozen_string_literal: true

require 'nodaire'

describe Nodaire::Tablatal do
  let(:instance) { described_class.new(input) }

  let(:input) do
    <<~TBTL
      NAME    AGE   COLOR
      Erica   12    Opal
      Alex    23    Cyan
      Nike    34    Red
      Ruca    45    Grey
    TBTL
  end

  describe '.parse' do
    let(:result) { described_class.parse(input) }

    let(:expected_output) do
      [
        { name: 'Erica', age: '12', color: 'Opal' },
        { name: 'Alex',  age: '23', color: 'Cyan' },
        { name: 'Nike',  age: '34', color: 'Red' },
        { name: 'Ruca',  age: '45', color: 'Grey' },
      ]
    end

    it 'returns the expected output' do
      expect(result).to eq expected_output
    end
  end
end
