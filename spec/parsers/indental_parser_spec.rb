# frozen_string_literal: true

require 'nodaire'

describe Nodaire::Indental::Parser do
  let(:instance) do
    described_class.new(input)
  end

  let(:input) do
    <<~NDTL
      NAME
        KEY : VALUE
        LIST
          ITEM1
          ITEM2
    NDTL
  end

  describe '#data' do
    let(:result) { instance.data }

    let(:expected_output) do
      {
        name: {
          key: 'VALUE',
          list: %w[ITEM1 ITEM2],
        }
      }
    end

    it 'returns the expected output' do
      expect(result).to eq expected_output
    end
  end
end
