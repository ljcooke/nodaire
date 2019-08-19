# frozen_string_literal: true

require_relative 'lexer'

class Nodaire::Indental
  # @private
  class Lexer < Nodaire::Lexer
    # @private
    Token = Struct.new(:type, :value, :symbol, :line_num)

    def self.tokenize(source)
      numbered_lines(strip_js_wrapper(source))
        .reject { |line, _| line.match(/^\s*(;.*)?$/) }
        .map { |line, num| token_for_line(line, num) }
    end

    def self.token_for_line(line, num)
      case line.match(/^\s*/)[0].size
      when 0 then category_token(line, num)
      when 2 then key_or_list_token(line, num)
      when 4 then list_item_token(line, num)
      else error_token('Unexpected indent', num)
      end
    end

    def self.category_token(string, line_num)
      token :category, string, line_num
    end

    def self.key_or_list_token(string, line_num)
      if string.include?(' : ')
        token :key_value, string.split(' : ', 2), line_num
      else
        token :list_name, string, line_num
      end
    end

    def self.list_item_token(string, line_num)
      token :list_item, string, line_num, symbolize: false
    end

    def self.error_token(message, line_num)
      token :error, message, line_num, symbolize: false
    end

    def self.token(token_type, value, line_num, symbolize: true)
      symbol = symbolized(value) if symbolize
      Token.new(token_type, normalized(value), symbol, line_num)
    end

    def self.normalized(input)
      case input
      when Array then input.map { |s| normalized(s) }
      when String then collapse_spaces(input)
      end
    end

    def self.symbolized(input)
      case input
      when Array then symbolized(input.first)
      when String
        input.downcase.gsub(/[\s_-]+/, ' ').split.join('_').to_sym
      end
    end
  end
end
