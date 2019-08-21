# frozen_string_literal: true

require_relative 'base'

module Nodaire
  # @private
  class Lexer
    JS_WRAPPER_REGEXP = %r{
      ^ \s*[^\n`]+ = [[:blank:]]* ` [[:blank:]]* \n
      (.*\n)
      [[:blank:]]* ` \s* $
    }mx.freeze

    def self.lines_with_number(source)
      (source || '')
        .split("\n").each_with_index
        .map { |line, idx| [line, idx + 1] }
    end

    def self.collapse_spaces(source)
      (source || '').split.join(' ')
    end

    def self.strip_js_wrapper(source)
      (source || '').sub(JS_WRAPPER_REGEXP, '\1')
    end
  end
end
