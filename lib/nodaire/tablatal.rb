# frozen_string_literal: true

# Implementation of Tablatal
# Tablatal is (c) Devine Lu Linvega (MIT License)

class Nodaire::Tablatal
  class ParserError < StandardError; end

  def self.parse(string)
    lines = (string || '').strip.split("\n")
                          .reject { |line| line.match(/^\s*(;.*)?$/) }
    return if lines.empty?

    keys = make_keys(lines.shift.scan(/(\S+\s*)/).flatten)
    lines.map { |line| make_line(line, keys) }.compact
  end

  class << self
    def make_keys(segs)
      [].tap do |keys|
        start = 0
        segs.each_with_index do |seg, idx|
          key = seg.strip.downcase.to_sym
          len = seg.size if idx < segs.size - 1
          raise ParserError, 'Duplicate keys' if keys.any? { |k| k[0] == key }

          keys.push [key, start...(len && start + len)]
          start += len if len
        end
      end
    end

    def make_line(line, keys)
      keys.map { |key, range| [key, line[range].strip] }.to_h
    end
  end
end
