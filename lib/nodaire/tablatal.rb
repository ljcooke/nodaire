# Based on tablatal.js by Devine Lu Linvega (MIT License)

module Nodaire
  class Tablatal
    class ParserError < StandardError; end

    def self.parse(string)
      lines = (string || '').strip.split("\n")
      return if lines.empty?
      keys = make_keys lines.shift.scan(/(\S+\s*)/).flatten
      lines.map do |line|
        next if line.match /^\s*(;.*)?$/
        keys.map { |key, range| [key, line[range].strip] }.to_h
      end.compact
    end

    def self.make_keys(segs)
      [].tap do |keys|
        start = 0
        segs.each_with_index do |seg, idx|
          key = seg.strip.downcase.to_sym
          len = seg.size if idx < segs.size - 1
          raise ParserError, 'Duplicate keys' if keys.any? { |k| k.first == key }
          keys.push [key, start...(len && start + len)]
          start += len if len
        end
      end
    end
  end
end
