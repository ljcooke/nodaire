# frozen_string_literal: true

require_relative '../errors'

class Nodaire::Parser # :nodoc:
  attr_reader :errors, :options

  def initialize(strict, options = {})
    @strict = strict
    @options = options
    @errors = []
  end

  def strict?
    @strict
  end

  def option(name, default = nil)
    @options.fetch(name, default)
  end

  def oops!(message, line_num)
    message = "#{message} on line #{line_num}" unless line_num.nil?
    errors << message
    raise Nodaire::ParserError, message if strict?
  end
end
