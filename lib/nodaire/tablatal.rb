# frozen_string_literal: true

require 'csv'

##
# Parser for the Tablatal file format.
#
# Tablatal is (c) Devine Lu Linvega (MIT License).
#
class Nodaire::Tablatal
  class ParserError < StandardError; end

  ##
  # Parse a string containing Tablatal data.
  #
  def initialize(string)
    lines = (string || '').strip.split("\n")
                          .reject { |line| line.match(/^\s*(;.*)?$/) }
    return if lines.empty?

    @keys = make_keys(lines.shift.scan(/(\S+\s*)/).flatten)
    @data = lines.map { |line| make_line(line) }.compact
  end

  ##
  # Returns an array of lowercase symbols representing the keys, in the order
  # declared in the Tablatal data.
  #
  def keys
    @keys.map(&:first) if @keys
  end

  ##
  # Returns the Tablatal data as an array of hashes.
  # Each key is a lowercase symbol.
  #
  def to_a
    @data.dup if @data
  end

  ##
  # Returns a CSV string representation of the Tablatal data.
  #
  def to_csv
    ordered_keys = keys
    CSV.generate do |csv|
      csv << ordered_keys.map(&:upcase)
      to_a.each do |row|
        csv << ordered_keys.map { |key| row[key] }
      end
    end
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
    @keys.map { |key, range| [key, (line[range] || '').strip] }.to_h
  end
end
