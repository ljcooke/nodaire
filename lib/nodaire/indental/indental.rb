# frozen_string_literal: true

require 'json'

require_relative 'parser'

##
# Interface for documents in Indental format.
#
# Indental is a text file format which represents a 'dictionary-type database'.
# This format was created by Devine Lu Linvega --
# see https://wiki.xxiivv.com/#indental for more information.
#
# @example
#   require 'nodaire/indental'
#
#   source = <<~NDTL
#     NAME
#       KEY : VALUE
#       LIST
#         ITEM1
#         ITEM2
#   NDTL
#
#   doc = Nodaire::Indental.parse(source)
#
#   doc.valid?
#   #=> true
#
#   doc.categories
#   #=> ["NAME"]
#
#   doc['NAME']['KEY']
#   #=> "VALUE"
#
#   doc.to_h
#   #=> {"NAME" => {"KEY"=>"VALUE", "LIST"=>["ITEM1", "ITEM2"]}}
#
#   doc.to_json
#   #=> '{"NAME":{"KEY":"VALUE","LIST":["ITEM1","ITEM2"]}}'
#
# @since 0.2.0
#
class Nodaire::Indental
  include Enumerable

  # @deprecated This will be removed in a future release. Use {#to_h} instead.
  # @return [Hash]
  attr_reader :data
  # @return [Array<String>] the category names.
  # @since 0.3.0
  attr_reader :categories
  # @return [Array<String>] an array of zero or more error message strings.
  # @see #valid?
  attr_reader :errors

  ##
  # Parse the document `source`.
  #
  # @example Read an Indental file
  #   source = File.read('example.ndtl')
  #
  #   doc = Nodaire::Indental.parse(source)
  #   puts doc['MY CATEGORY']
  #
  # @example Read an Indental file and symbolize names
  #   source = File.read('example.ndtl')
  #
  #   doc = Nodaire::Indental.parse(source, symbolize_names: true)
  #   puts doc[:my_category]
  #
  # @param [String] source The document source to parse.
  # @param [Boolean] symbolize_names
  #   If `true`, normalize category and key names and convert them to
  #   lowercase symbols.
  #   If `false`, convert category and key names to uppercase strings.
  #
  # @return [Indental]
  #
  def self.parse(source, symbolize_names: false)
    parser = Parser.new(source, false, symbolize_names: symbolize_names)

    new(parser)
  end

  ##
  # Parse the document `source`, raising an exception if a parser error occurs.
  #
  # @example Error handling
  #   begin
  #     doc = Nodaire::Indental.parse(source)
  #     puts doc['EXAMPLE']
  #   rescue Nodaire::ParserError => error
  #     puts error
  #   end
  #
  # @param (see .parse)
  #
  # @return [Indental]
  # @raise [ParserError]
  #
  def self.parse!(source, symbolize_names: false)
    parser = Parser.new(source, true, symbolize_names: symbolize_names)

    new(parser)
  end

  ##
  # @return [String] a human-readable representation of this class.
  # @since UNRELEASED
  #
  def inspect
    "\#<#{self.class.name} #{@data}>"
  end
  alias_method :to_s, :inspect

  ##
  # @return [Boolean] whether the source was parsed without errors.
  # @see #errors
  #
  def valid?
    @errors.empty?
  end

  ##
  # Returns the data for a given `category`.
  #
  # @example
  #   doc = Nodaire::Indental.parse(source)
  #   puts doc['CATEGORY']
  #
  # @return [Hash] the data for `category`. If not found, returns `nil`.
  # @since 0.5.0
  #
  def [](category)
    @data[category]
  end

  ##
  # Convert the document to a hash.
  #
  # @return [Hash]
  #
  def to_h(*args)
    @data.to_h(*args)
  end

  ##
  # Convert the document to JSON.
  #
  # @return [String]
  #
  def to_json(*args)
    @data.to_json(*args)
  end

  # Enumerable
  # @private
  def each(&block)
    @data.each(&block)
  end

  private

  def initialize(parser)
    @data = parser.data
    @errors = parser.errors

    @categories = data.keys
  end
end
