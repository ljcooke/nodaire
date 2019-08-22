# frozen_string_literal: true

require 'nodaire/util'

describe Nodaire do
  shared_examples 'it returns the expected output' do
    it 'returns the expected output' do
      expect(output).to eq expected_output
    end
  end

  describe '.squeeze' do
    let(:output) { described_class.squeeze(input) }
    let(:expected_output) { 'this is a string' }

    context 'with leading and trailing whitespace' do
      let(:input) { " \t this is a string \t\n\t" }

      it_behaves_like 'it returns the expected output'
    end

    context 'with sequences of mixed whitespace characters' do
      let(:input) { "this \n is\t\n a\r\n string" }

      it_behaves_like 'it returns the expected output'
    end

    context 'with no input' do
      let(:input) { nil }
      let(:expected_output) { '' }

      it_behaves_like 'it returns the expected output'
    end
  end

  describe '.symbolize' do
    let(:output) { described_class.symbolize(input) }
    let(:expected_output) { :hello_world }

    context 'with mixed case and punctuation' do
      let(:input) { 'Hello, WORLD' }

      it_behaves_like 'it returns the expected output'
    end

    context 'with mixed spacing' do
      let(:input) { " hello \t world " }

      it_behaves_like 'it returns the expected output'
    end

    context 'with leading and trailing punctuation' do
      let(:input) { ' _hello world !!!' }
      let(:expected_output) { :_hello_world_ }

      it_behaves_like 'it returns the expected output'
    end

    context 'with no input' do
      let(:input) { nil }
      let(:expected_output) { :'' }

      it_behaves_like 'it returns the expected output'
    end
  end
end
