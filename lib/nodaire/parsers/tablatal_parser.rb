# frozen_string_literal: true

require 'set'

require_relative 'parser'

class Nodaire::Tablatal
  # @private
  class Parser < Nodaire::Parser
    attr_reader :data

    def initialize(string, strict, options = {})
      super(strict, options)

      @symbolize_names = option(:symbolize_names, false)
      @data = []
      @keys = []

      parse! string
    end

    def keys
      @keys.map(&:name)
    end

    private

    attr_reader :symbolize_names

    Key = Struct.new(:name, :range, keyword_init: true)

    def parse!(string)
      lines = (string || '').strip.split("\n")
                            .reject { |line| line.match(/^\s*(;.*)?$/) }
      return if lines.empty?

      @keys = make_keys(lines.shift.scan(/(\S+\s*)/).flatten)
      @data = lines.map { |line| make_line(line) }.compact
    end

    def make_keys(segs)
      [].tap do |keys|
        start = 0
        keys_seen = Set.new
        segs.each_with_index do |seg, idx|
          len = seg.size if idx < segs.size - 1
          key = normalize_key(seg)

          if keys_seen.include?(key)
            oops! "Duplicate key #{key}", 1
          else
            range_end = len ? start + len - 1 : -1
            keys_seen << key
            keys << Key.new(name: key, range: start..range_end)
          end

          start += len if len
        end
      end
    end

    def make_line(line)
      @keys.map { |key| [key.name, normalize_text(line[key.range])] }.to_h
    end

    def normalize_text(string)
      string ? string.split.join(' ') : ''
    end

    def normalize_key(string)
      if symbolize_names
        normalize_text(string).downcase.gsub(/[^a-z0-9]+/, '_').to_sym
      else
        normalize_text(string).upcase
      end
    end
  end
end
