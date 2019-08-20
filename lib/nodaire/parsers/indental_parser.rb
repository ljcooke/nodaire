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
      tokens.each { |token| parse_token!(normalize_token(token)) }
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
      if category_ids.include?(token.key)
        oops! 'Duplicate category', token.line_num
        self.category = nil
      else
        self.category = Category.new(
          name: token.key,
          key_ids: {},
          list_id: nil
        )
        data[token.key] = {}
        category_ids[token.key] = token.key
      end
    end

    def parse_key_value!(token)
      return oops!('No category specified', token.line_num) if category.nil?

      if category.key_ids.include?(token.key)
        oops! 'Duplicate key', token.line_num
        category.list_id = nil
      else
        add_key_value! token
      end
    end

    def parse_list_name!(token)
      return oops!('No category specified', token.line_num) if category.nil?

      if category.key_ids.include?(token.key)
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
      data[category.name][token.key] = token.value
      category.key_ids[token.key] = token.key
      category.list_id = nil
    end

    def add_list!(token)
      data[category.name][token.key] = []
      category.key_ids[token.key] = token.key
      category.list_id = token.key
    end

    def add_list_item!(token)
      data[category.name][category.list_id] << token.value
    end

    def parse_error!(token)
      oops! token.value, token.line_num
    end

    def normalize_token(token)
      token.tap { |t| t.key = normalize_key(t.key) }
    end

    def normalize_key(key)
      if symbolize_names && key
        key.downcase.gsub(/[\s_-]+/, ' ').split.join('_').to_sym
      else
        key
      end
    end
  end
end
