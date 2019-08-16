# frozen_string_literal: true

require 'csv'

require 'nodaire/errors'

class Nodaire::Tablatal
  class ParserError < Nodaire::ParserError; end

  ##
  # Parser for the Tablatal file format.
  #
  # Tablatal is (c) Devine Lu Linvega (MIT License).
  #
  class Parser
    attr_reader :rows

    def initialize(string, preserve_keys: false)
      lines = (string || '').strip.split("\n")
                            .reject { |line| line.match(/^\s*(;.*)?$/) }
      return if lines.empty?

      @keys = make_keys(lines.shift.scan(/(\S+\s*)/).flatten, preserve_keys)
      @rows = lines.map { |line| make_line(line) }.compact
    end

    def to_csv
      key_symbols = keys
      CSV.generate do |csv|
        csv << key_symbols
        rows.each do |row|
          csv << key_symbols.map { |key| row[key] }
        end
      end
    end

    def keys
      @keys.map(&:name) if @keys
    end

    private

    Key = Struct.new(:name, :range, keyword_init: true)

    def make_keys(segs, preserve_keys)
      [].tap do |keys|
        segs.each_with_index do |seg, idx|
          key = seg.strip
          key = key.downcase.to_sym unless preserve_keys
          raise ParserError, 'Duplicate keys' if keys.any? { |k| key == k.name }

          len = seg.size if idx < segs.size - 1
          start = keys.empty? ? 0 : keys.last.range.last
          keys.push Key.new(name: key, range: start...(len && start + len))
        end
      end
    end

    def make_line(line)
      @keys.map { |key| [key.name, (line[key.range] || '').strip] }.to_h
    end
  end
end
