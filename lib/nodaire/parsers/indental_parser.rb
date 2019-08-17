# frozen_string_literal: true

require_relative '../errors'

class Nodaire::Indental
  class ParserError < Nodaire::ParserError; end

  class Parser
    attr_reader :data, :errors

    def initialize(string, strict, options = {})
      @strict = strict
      @preserve_keys = options.fetch(:preserve_keys, false)

      @data = {}
      @errors = []

      parse! string
    end

    private

    def parse!(string)
      (string || '')
        .split("\n").each_with_index
        .reject { |line, _| line.match(/^\s*(;.*)?$/) }
        .each { |line, idx| parse_line! line, idx + 1 }
    end

    def parse_line!(line, num)
      case line.match(/^\s*/)[0].size
      when 0 then parse_category! line.strip, num
      when 2 then parse_key_or_list! line.strip, num
      when 4 then parse_list_item! line.strip, num
      else oops! 'Unexpected indent', num
      end
    end

    def parse_category!(cat, num)
      cat = symbolize_key(cat)
      if data.include?(cat)
        @cat_id = nil
        @list_id = nil
        oops! 'Duplicate category', num
      else
        @data[cat] = {}
        @cat_id = cat
        @list_id = nil
      end
    end

    def parse_key_or_list!(line, num)
      return oops!('No category specified', num) unless @cat_id

      if line.include?(' : ')
        key, value = line.split(' : ', 2)
        parse_key_value!(key.strip, value.strip, num)
      else
        parse_list!(line, num)
      end
    end

    def parse_key_value!(key, value, num)
      key = symbolize_key(key)
      if @data[@cat_id].include?(key)
        @list_id = nil
        oops! 'Duplicate key', num
      else
        @data[@cat_id][key] = value.strip
        @list_id = nil
      end
    end

    def parse_list!(key, num)
      key = symbolize_key(key)
      if @data[@cat_id].include?(key)
        @list_id = nil
        oops! 'Duplicate key', num
      else
        @data[@cat_id][key] = []
        @list_id = key
      end
    end

    def parse_list_item!(item, num)
      if @list_id.nil?
        oops! 'No list specified', num
      else
        @data[@cat_id][@list_id] << item
      end
    end

    def oops!(message, line_num)
      message = "#{message} on line #{line_num}"
      @errors << message
      raise ParserError, message if @strict
    end

    def symbolize_key(key)
      @preserve_keys ? key : key.downcase.split.join('_').to_sym
    end
  end
end
