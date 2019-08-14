# frozen_string_literal: true

# Implementation of Tablatal
# Tablatal is (c) Devine Lu Linvega (MIT License)

module Nother
  class Tablatal
    class ParserError < StandardError; end

    def self.parse(string)
      lines = (string || '').strip.split("\n")
      return if lines.empty?
      keys = make_keys lines.shift.scan(/(\S+\s*)/).flatten
      lines.map do |line|
        next if line.match(/^\s*(;.*)?$/)
        keys.map { |key, range| [key, line[range].strip] }.to_h
      end.compact
    end

    def self.make_keys(segs)
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
    private_class_method :make_keys
  end
end
