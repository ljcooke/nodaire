# frozen_string_literal: true

require 'set'

require_relative '../parser'

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

      @keys = filter_keys(make_keys(lines.shift.scan(/(\S+\s*)/).flatten))
      @data = lines.map { |line| make_line(line) }.compact
    end

    def make_keys(segs)
      keys = []
      start = 0
      segs.each_with_index do |seg, idx|
        len = seg.size if idx < segs.size - 1
        range_end = len ? start + len - 1 : -1
        keys << Key.new(name: normalize_key(seg), range: start..range_end)
        start += len if len
      end
      keys
    end

    def filter_keys(keys)
      result = []
      keys.each do |key|
        if result.any? { |k| k.name == key.name }
          oops! "Duplicate key #{key.name}", 1
        else
          result << key
        end
      end
      result
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
