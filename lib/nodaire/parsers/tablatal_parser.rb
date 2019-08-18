# frozen_string_literal: true

require_relative '../errors'

class Nodaire::Tablatal
  class ParserError < Nodaire::ParserError; end

  class Parser # :nodoc:
    attr_reader :data, :errors

    def initialize(string, strict, options = {})
      @strict = strict
      @symbolize_names = options.fetch(:symbolize_names, false)

      @data = []
      @errors = []

      @keys = []
      @key_ids = {}

      parse! string
    end

    def keys
      @keys.map(&:name)
    end

    private

    attr_reader :strict, :symbolize_names, :key_ids

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
        segs.each_with_index do |seg, idx|
          len = seg.size if idx < segs.size - 1
          id = normalize_sym(seg)
          key_name = symbolize_names ? id : normalize_text(seg)

          if key_ids.include?(id)
            oops! "Duplicate key #{key_name}", 1
          else
            range_end = len ? start + len - 1 : -1
            key_ids[id] = key_name
            keys << Key.new(name: key_name, range: start..range_end)
          end

          start += len if len
        end
      end
    end

    def make_line(line)
      @keys.map { |key| [key.name, normalize_text(line[key.range])] }.to_h
    end

    def oops!(message, line_num)
      message = "#{message} on line #{line_num}"
      errors << message
      raise ParserError, message if strict
    end

    def normalize_text(string)
      string ? string.split.join(' ') : ''
    end

    def normalize_sym(key)
      key.downcase.gsub(/[_-]+/, ' ').split.join('_').to_sym
    end
  end
end
