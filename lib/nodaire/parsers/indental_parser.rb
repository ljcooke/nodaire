# frozen_string_literal: true

require_relative '../errors'

class Nodaire::Indental
  class ParserError < Nodaire::ParserError; end

  class Parser
    attr_reader :data

    def initialize(string)
      @data = {}
    end
  end
end
