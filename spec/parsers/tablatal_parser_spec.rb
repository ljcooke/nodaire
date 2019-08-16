# frozen_string_literal: true

require 'nodaire/parsers/tablatal_parser'

describe Nodaire::Tablatal::Parser do
  let(:preserve_keys) { false }
  let(:instance) do
    described_class.new(input, preserve_keys: preserve_keys)
  end

  let(:input) do
    <<~TBTL
      NAME    AGE   COLOR
      Erica   12    Opal
      Alex    23    Cyan, Turquoise
      Nike    34    赤い
      Ruca    45    Grey
    TBTL
  end

  describe '#rows' do
    let(:result) { instance.rows }

    let(:expected_output) do
      [
        { name: 'Erica', age: '12', color: 'Opal' },
        { name: 'Alex',  age: '23', color: 'Cyan, Turquoise' },
        { name: 'Nike',  age: '34', color: '赤い' },
        { name: 'Ruca',  age: '45', color: 'Grey' },
      ]
    end

    it 'returns the expected output' do
      expect(result).to eq expected_output
    end

    context 'with preserve_keys set to true' do
      let(:preserve_keys) { true }

      let(:expected_output) do
        [
          { 'NAME' => 'Erica', 'AGE' => '12', 'COLOR' => 'Opal' },
          { 'NAME' => 'Alex',  'AGE' => '23', 'COLOR' => 'Cyan, Turquoise' },
          { 'NAME' => 'Nike',  'AGE' => '34', 'COLOR' => '赤い' },
          { 'NAME' => 'Ruca',  'AGE' => '45', 'COLOR' => 'Grey' },
        ]
      end

      it 'returns the expected output' do
        expect(result).to eq expected_output
      end
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
        expect(result).to be_nil
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
        expect { result }.to raise_error Nodaire::Tablatal::ParserError
      end
    end

    context 'with leading whitespace' do
      let(:input) do
        <<~TBTL
           NAME   AGE   COLOR
          Erica   12    Opal
          Alex    23    Cyan, Turquoise
          Nike    34    赤い
          Ruca    45    Grey
        TBTL
      end

      it 'returns the expected output' do
        expect(result).to eq expected_output
      end
    end

    context 'with trailing spaces' do
      let(:spaces) { ' ' }
      let(:input) do
        <<~TBTL
          NAME    AGE   COLOR#{spaces}
          Erica   12    Opal
          Alex    23    Cyan, Turquoise\t\t
          Nike    34    赤い
          Ruca    45    Grey#{spaces}
        TBTL
      end

      it 'returns the expected output' do
        expect(result).to eq expected_output
      end
    end

    context 'with misaligned entries' do
      context 'shifted left' do
        let(:input) do
          <<~TBTL
            NAME    AGE   COLOR
            Erica   12   Opal
            Alex    23    Cyan, Turquoise
            Nike    34    赤い
            Ruca    45    Grey
          TBTL
        end

        it 'returns corrupted output' do
          expect(result).not_to eq expected_output
          expect(result.first[:age]).to eq '12   O'
          expect(result.first[:color]).to eq 'pal'
        end
      end

      context 'shifted right (staying within the column width)' do
        let(:input) do
          <<~TBTL
            NAME    AGE   COLOR
            Erica   12    Opal
             Alex    23   \tCyan, Turquoise
            Nike    34     赤い
             Ruca    45   Grey
          TBTL
        end

        it 'returns the expected output' do
          expect(result).to eq expected_output
        end
      end
    end

    context 'with entries filling the column width' do
      let(:input) do
        <<~TBTL
          NAME AGE   COLOR
          Erica12    Opal
          Alex 23    Cyan, Turquoise
          Nike 34    赤い
          Ruca 45    Grey
        TBTL
      end

      it 'returns the expected output' do
        expect(result).to eq expected_output
      end
    end

    context 'with incomplete lines' do
      let(:input) do
        <<~TBTL
          NAME    AGE   COLOR
          Erica   12    Opal
          Alex    23
          Nike    34    赤い
          Ruca
        TBTL
      end

      let(:expected_output) do
        [
          { name: 'Erica', age: '12', color: 'Opal' },
          { name: 'Alex',  age: '23', color: '' },
          { name: 'Nike',  age: '34', color: '赤い' },
          { name: 'Ruca',  age: '',   color: '' },
        ]
      end

      it 'sets the missing values to empty strings' do
        expect(result).to eq expected_output
      end
    end
  end

  describe '#keys' do
    let(:result) { instance.keys }

    let(:expected_output) do
      %i[name age color]
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
        expect(result).to be_nil
      end
    end

    context 'with one line' do
      let(:input) { 'NAME    AGE   COLOR' }

      it 'returns an empty array' do
        expect(result).to eq expected_output
      end
    end
  end

  describe '#to_csv' do
    let(:result) { instance.to_csv }

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
      expect(result).to eq expected_output
    end
  end
end
