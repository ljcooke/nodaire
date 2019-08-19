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

    def parse_category!(token)
      if category_ids.include?(token.symbol)
        oops! 'Duplicate category', token.line_num
        self.category = nil
      else
        self.category = Category.new(
          name: token_name(token),
          key_ids: {},
          list_id: nil
        )
        data[category.name] = {}
        category_ids[token.symbol] = category.name
      end
    end

    def parse_key_value!(token)
      return oops!('No category specified', token.line_num) if category.nil?

      if category.key_ids.include?(token.symbol)
        oops! 'Duplicate key', token.line_num
        category.list_id = nil
      else
        add_key_value! token
      end
    end

    def parse_list_name!(token)
      return oops!('No category specified', token.line_num) if category.nil?

      if category.key_ids.include?(token.symbol)
        oops! 'Duplicate key for list', token.line_num
        category.list_id = nil
      else
        add_list! token
      end
    end

    def parse_list_item!(token)
      if category.nil? || category.list_id.nil?
        oops! 'No list specified', token.line_num
      else
        add_list_item! token
      end
    end

    def add_key_value!(token)
      key_name = token_name(token)
      data[category.name][key_name] = token.value.last
      category.key_ids[token.symbol] = key_name
      category.list_id = nil
    end

    def add_list!(token)
      list_name = token_name(token)
      data[category.name][list_name] = []
      category.key_ids[token.symbol] = list_name
      category.list_id = token.symbol
    end

    def add_list_item!(token)
      list_name = category.key_ids[category.list_id]
      data[category.name][list_name] << token.value
    end

    def parse_error!(token)
      oops! token.value, token.line_num
    end

    def token_name(token)
      return token.symbol if symbolize_names

      case token.value
      when Array then token.value.first
      when String then token.value
      end
    end
  end
end
