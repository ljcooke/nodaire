# frozen_string_literal: true

# Implementation of Tablatal
# Tablatal is (c) Devine Lu Linvega (MIT License)

class Nodaire::Tablatal
  class ParserError < StandardError; end

  def initialize(string)
    lines = (string || '').strip.split("\n")
                          .reject { |line| line.match(/^\s*(;.*)?$/) }
    unless lines.empty?
      @keys = make_keys(lines.shift.scan(/(\S+\s*)/).flatten)
      @data = lines.map { |line| make_line(line) }.compact
    end
  end

  def to_a
    @data.dup if @data
  end

  def keys
    @keys.map(&:first) if @keys
  end

  private

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

  def make_line(line)
    @keys.map { |key, range| [key, line[range].strip] }.to_h
  end
end
