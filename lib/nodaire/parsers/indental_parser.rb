# frozen_string_literal: true

require_relative 'parser'

class Nodaire::Indental
  class Parser < Nodaire::Parser # :nodoc:
    attr_reader :data

    def initialize(string, strict, options = {})
      super(strict, options)

      @symbolize_names = option(:symbolize_names, false)
      @data = {}
      @category_ids = {}
      @category = nil

      parse! string
    end

    private

    Category = Struct.new(:name, :key_ids, :list_id, keyword_init: true)

    attr_accessor :category
    attr_reader :symbolize_names, :category_ids

    def parse!(string)
      lines = lines_to_parse(string)
      lines = lines[1...-1] if js_wrapper?(lines)
      lines.each { |line, num| parse_line! line, num }
    end

    def lines_to_parse(string)
      (string || '')
        .split("\n").each_with_index
        .reject { |line, _| line.match(/^\s*(;.*)?$/) }
        .map { |line, idx| [line, idx + 1] }
    end

    def js_wrapper?(lines)
      !lines.empty? &&
        lines.first[0].match(/=\s*`\s*$/) &&
        lines.last[0].strip == '`'
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
      id = normalize_sym(cat)

      if category_ids.include?(id)
        oops! 'Duplicate category', num
        self.category = nil
      else
        self.category = Category.new(
          name: symbolize_names ? id : normalize_text(cat),
          key_ids: {},
          list_id: nil
        )
        data[category.name] = {}
        category_ids[id] = category.name
      end
    end

    def parse_key_or_list!(line, num)
      return oops!('No category specified', num) if category.nil?

      if line.include?(' : ')
        key, value = line.split(' : ', 2)
        parse_key_value!(key, value, num)
      else
        parse_list!(line, num)
      end
    end

    def parse_key_value!(key, value, num)
      id = normalize_sym(key)
      key_name = symbolize_names ? id : normalize_text(key)

      if category.key_ids.include?(id)
        oops! 'Duplicate key', num
      else
        data[category.name][key_name] = normalize_text(value)
        category.key_ids[id] = key_name
      end

      category.list_id = nil
    end

    def parse_list!(key, num)
      id = normalize_sym(key)
      list_name = symbolize_names ? id : normalize_text(key)

      if category.key_ids.include?(id)
        oops! 'Duplicate key for list', num
        category.list_id = nil
      else
        data[category.name][list_name] = []
        category.key_ids[id] = list_name
        category.list_id = id
      end
    end

    def parse_list_item!(item, num)
      if category.nil? || category.list_id.nil?
        oops! 'No list specified', num
      else
        list_name = category.key_ids[category.list_id]
        data[category.name][list_name] << normalize_text(item)
      end
    end

    def normalize_text(string)
      string.split.join(' ')
    end

    def normalize_sym(key)
      key.downcase.gsub(/[\s_-]+/, ' ').split.join('_').to_sym
    end
  end
end
