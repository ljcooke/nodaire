# frozen_string_literal: true

require 'nodaire'

describe Nodaire::Lexer do
  describe '.lines_with_number' do
    let(:output) { described_class.lines_with_number(input) }

    context 'with no input' do
      let(:input) { nil }

      it 'returns an empty array' do
        expect(output).to eq []
      end
    end

    context 'with a string' do
      let(:input) do
        <<~SOURCE

          line 2
          \t line \t 3 \t
          \t
        SOURCE
      end

      it 'returns pairs of unmodified strings and line numbers' do
        expect(output).to eq [
          ['', 1],
          ['line 2', 2],
          ["\t line \t 3 \t", 3],
          ["\t", 4],
        ]
      end
    end
  end

  describe '.strip_js_wrapper' do
    let(:output) { described_class.strip_js_wrapper(input) }

    context 'with no input' do
      let(:input) { nil }

      it 'returns an empty string' do
        expect(output).to eq ''
      end
    end

    context 'with text contained in a JS wrapper' do
      let(:input) do
        <<~SOURCE
          app.example = `
          HELLO
          WORLD
          `
        SOURCE
      end

      let(:expected_result) { "HELLO\nWORLD\n" }

      it 'removes the first and last line' do
        expect(output).to eq expected_result
      end

      context 'with extra whitespace' do
        let(:input) do
          <<~SOURCE

            app.example = `\t
            HELLO
            WORLD
            \t`\t

          SOURCE
        end

        it 'removes the first and last line' do
          expect(output).to eq expected_result
        end
      end
    end

    context 'with an incomplete wrapper' do
      context 'missing an opening delimiter' do
        let(:input) do
          <<~SOURCE
            app.example =
            HELLO
            WORLD
            `
          SOURCE
        end

        it 'returns the input unchanged' do
          expect(output).to eq input
        end
      end

      context 'missing a closing delimiter' do
        let(:input) do
          <<~SOURCE
            app.example = `
            HELLO
            WORLD
          SOURCE
        end

        it 'returns the input unchanged' do
          expect(output).to eq input
        end
      end
    end
  end
end
