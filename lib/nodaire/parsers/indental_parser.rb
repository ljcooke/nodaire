# frozen_string_literal: true

require_relative '../lexers/indental_lexer'
require_relative 'parser'

class Nodaire::Indental
  # @private
  class Parser < Nodaire::Parser
    attr_reader :data

    def initialize(source, strict, options = {})
      super(strict, options)

      @symbolize_names = option(:symbolize_names, false)
      @data = {}
      @category_ids = {}
      @category = nil

      parse! Nodaire::Indental::Lexer.tokenize(source)
    end

    private

    Category = Struct.new(:name, :key_ids, :list_id, keyword_init: true)

    attr_accessor :category
    attr_reader :symbolize_names, :category_ids

    def parse!(tokens)
      tokens.each { |token| parse_token! token }
    end

    def parse_token!(token)
      case token.type
      when :category then parse_category! token
      when :key_value then parse_key_value! token
      when :list_name then parse_list_name! token
      when :list_item then parse_list_item! token
      when :error then parse_error! token
      end
    end

    # @todo
    def js_wrapper?(lines)
      !lines.empty? &&
        lines.first[0].match(/=\s*`\s*$/) &&
        lines.last[0].strip == '`'
    end

    def parse_category!(token)
      id = token.symbol

      if category_ids.include?(id)
        oops! 'Duplicate category', token.line_num
        self.category = nil
      else
        self.category = Category.new(
          name: symbolize_names ? id : token.value,
          key_ids: {},
          list_id: nil
        )
        data[category.name] = {}
        category_ids[id] = category.name
      end
    end

    def parse_key_value!(token)
      return oops!('No category specified', token.line_num) if category.nil?

      key, value = token.value
      id = token.symbol
      key_name = symbolize_names ? id : key

      if category.key_ids.include?(id)
        oops! 'Duplicate key', token.line_num
      else
        data[category.name][key_name] = value
        category.key_ids[id] = key_name
      end

      category.list_id = nil
    end

    def parse_list_name!(token)
      return oops!('No category specified', token.line_num) if category.nil?

      id = token.symbol
      list_name = symbolize_names ? id : token.value

      if category.key_ids.include?(id)
        oops! 'Duplicate key for list', token.line_num
        category.list_id = nil
      else
        data[category.name][list_name] = []
        category.key_ids[id] = list_name
        category.list_id = id
      end
    end

    def parse_list_item!(token)
      if category.nil? || category.list_id.nil?
        oops! 'No list specified', token.line_num
      else
        list_name = category.key_ids[category.list_id]
        data[category.name][list_name] << token.value
      end
    end

    def parse_error!(token)
      oops! token.value, token.line_num
    end

    def normalize_sym(string)
      string.downcase.gsub(/[\s_-]+/, ' ').split.join('_').to_sym
    end
  end
end
