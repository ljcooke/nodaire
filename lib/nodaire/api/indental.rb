# frozen_string_literal: true

require 'json'

require_relative '../parsers/indental_parser'

##
# Interface for documents in _Indental_ format.
#
# _Indental_ is a 'dictionary-type database format' by Devine Lu Linvega.
# See: https://wiki.xxiivv.com/#indental
#
#   require 'nodaire/indental'
#
#   doc = Nodaire::Indental.parse! <<~NDTL
#     {
#       'NAME' => {
#         'KEY' => 'VALUE',
#         'LIST' => ['ITEM1', 'ITEM2'],
#       },
#     }
#   NDTL
#
#   doc.valid?     # true
#   doc.categories # ["NAME"]
#   doc.to_h       # {"NAME"=>{"KEY"=>"VALUE", "LIST"=>["ITEM1", "ITEM2"]}}
#   doc.to_json    # '{"NAME":{"KEY":"VALUE","LIST":["ITEM1","ITEM2"]}}'
#
class Nodaire::Indental
  # A hash containing the data parsed from the source.
  attr_reader :data
  # An array of category names.
  attr_reader :categories
  # An array of error message strings.
  attr_reader :errors

  alias_method :to_h, :data

  ##
  # Parse the document +source+ and return an +Indental+ instance.
  # Ignores or attempts to work around errors.
  #
  # If +symbolize_names+ is +true+, normalizes category and key names
  # and converts them to lowercase symbols.
  #
  def self.parse(source, symbolize_names: false)
    parser = Parser.new(source, false, symbolize_names: symbolize_names)

    new(parser)
  end

  ##
  # Parse the document +source+ and return an +Indental+ instance.
  # Raises an exception if errors are detected.
  #
  # If +symbolize_names+ is +true+, normalizes category and key names
  # and converts them to lowercase symbols.
  #
  def self.parse!(source, symbolize_names: false)
    parser = Parser.new(source, true, symbolize_names: symbolize_names)

    new(parser)
  end

  ##
  # A boolean indicating whether the source was parsed without errors.
  #
  def valid?
    @errors.empty?
  end

  ##
  # Convert the document to JSON. Returns a string.
  #
  def to_json(*_args)
    JSON.generate(data)
  end

  private

  def initialize(parser)
    @data = parser.data
    @errors = parser.errors

    @categories = data.keys
  end
end
