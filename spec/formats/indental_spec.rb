# frozen_string_literal: true

require 'nodaire'

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
      name: {
        key: 'VALUE',
        list: %w[ITEM1 ITEM2],
      },
    }
  end

  describe '.parse' do
    let(:return_value) { described_class.parse(input) }

    it 'returns an instance of the class' do
      expect(return_value).to be_a described_class
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
  end
end
