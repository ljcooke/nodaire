# frozen_string_literal: true

require_relative 'base'

module Nodaire
  ##
  # This exception is raised if a parser error occurs.
  #
  # @deprecated This will be removed in a future release.
  # @since 0.1.0
  #
  class ParserError < StandardError; end
end
