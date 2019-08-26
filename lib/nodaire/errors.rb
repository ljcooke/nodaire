# frozen_string_literal: true

require_relative 'base'

module Nodaire
  ##
  # This exception is raised if a parser error occurs.
  #
  # @since 0.1.0
  #
  class ParserError < StandardError; end
end
