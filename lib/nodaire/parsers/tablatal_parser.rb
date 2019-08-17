# frozen_string_literal: true

require_relative '../errors'

class Nodaire::Tablatal
  class ParserError < Nodaire::ParserError; end

  class Parser
    attr_reader :data, :errors

    def initialize(string, strict, options = {})
      @strict = strict
      @preserve_keys = options.fetch(:preserve_keys, false)

      @errors = []

      parse! string
    end

    def keys
      @keys.map(&:name) if @keys
    end

    private

    Key = Struct.new(:name, :range, keyword_init: true)

    def parse!(string)
      lines = (string || '').strip.split("\n")
                            .reject { |line| line.match(/^\s*(;.*)?$/) }
      return if lines.empty?

      @keys = make_keys(lines.shift.scan(/(\S+\s*)/).flatten)
      @data = lines.map { |line, num| make_line(line, num) }.compact
    end

    def make_keys(segs)
      [].tap do |keys|
        start = 0
        segs.each_with_index do |seg, idx|
          key = symbolize_key(seg.strip)
          len = seg.size if idx < segs.size - 1

          if keys.any? { |k| key == k.name }
            oops! "Duplicate key #{key}", 1
          else
            keys << Key.new(name: key, range: start...(len && start + len))
          end

          start += len if len
        end
      end
    end

    def make_line(line, num)
      @keys.map { |key| [key.name, (line[key.range] || '').strip] }.to_h
    end

    def oops!(message, line_num)
      message = "#{message} on line #{line_num}"
      @errors << message
      raise ParserError, message if @strict
    end

    def symbolize_key(key)
      @preserve_keys ? key : key.downcase.to_sym
    end
  end
end
