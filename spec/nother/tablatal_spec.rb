require 'nother'

describe Nother::Tablatal do
  let(:input) do
    <<~EOF
      NAME    AGE   COLOR
      Erica   12    Opal
      Alex    23    Turquoise
      Nike    34    赤い
      Ruca    45    Grey
    EOF
  end

  let(:expected_output) do
    [
      { name: 'Erica', age: '12', color: 'Opal' },
      { name: 'Alex',  age: '23', color: 'Turquoise' },
      { name: 'Nike',  age: '34', color: '赤い' },
      { name: 'Ruca',  age: '45', color: 'Grey' },
    ]
  end

  describe '.parse' do
    let(:result) do
      described_class.parse(input)
    end

    it 'returns the expected output' do
      expect(result).to eq expected_output
    end

    context 'with no input' do
      let(:input) { nil }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end

    context 'with only whitespace' do
      let(:input) { '    ' }

      it 'returns nil' do
        expect(result).to eq nil
      end
    end

    context 'with one line' do
      let(:input) { 'NAME    AGE   COLOR' }

      it 'returns an empty array' do
        expect(result).to eq []
      end
    end

    context 'with duplicate keys' do
      let(:input) { 'NAME  AGE  COLOR  NAME' }

      it 'raises an error' do
        expect { result }.to raise_error Nother::Tablatal::ParserError
      end
    end

    context 'with trailing spaces' do
      let(:spaces) { ' ' }
      let(:input) do
        <<~EOF
          NAME    AGE   COLOR#{spaces}
          Erica   12    Opal
          Alex    23    Turquoise\t\t
          Nike    34    赤い
          Ruca    45    Grey#{spaces}
        EOF
      end

      it 'returns the expected output' do
        expect(result).to eq expected_output
      end
    end

    context 'with misaligned entries' do
      context 'shifted left' do
        let(:input) do
          <<~EOF
            NAME    AGE   COLOR
            Erica   12   Opal
            Alex    23    Turquoise
            Nike    34    赤い
            Ruca    45    Grey
          EOF
        end

        it 'returns corrupted output' do
          expect(result).not_to eq expected_output
          expect(result.first[:age]).to eq '12   O'
          expect(result.first[:color]).to eq 'pal'
        end
      end

      context 'shifted right (staying within the column width)' do
        let(:input) do
          <<~EOF
            NAME    AGE   COLOR
            Erica   12    Opal
             Alex    23   \tTurquoise
            Nike    34     赤い
             Ruca    45   Grey
          EOF
        end

        it 'returns the expected output' do
          expect(result).to eq expected_output
        end
      end
    end
  end
end
