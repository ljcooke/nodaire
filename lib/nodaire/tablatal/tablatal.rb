# frozen_string_literal: true

require 'csv'

require_relative 'parser'

##
# Interface for documents in Tablatal format.
#
# Tablatal is a text file format which represents a 'list-type database'.
# This format was created by Devine Lu Linvega --
# see https://wiki.xxiivv.com/#tablatal for more information.
#
# @example
#   require 'nodaire/tablatal'
#
#   source = <<~TBTL
#     NAME    AGE   COLOR
#     Erica   12    Opal
#     Alex    23    Cyan
#     Nike    34    Red
#     Ruca    45    Grey
#   TBTL
#
#   doc = Nodaire::Tablatal.parse(source)
#
#   doc.valid?
#   #=> true
#
#   doc.keys
#   #=> ["NAME", "AGE", "COLOR"]
#
#   doc[0]['NAME']
#   #=> "Erica"
#
#   doc.to_a
#   #=> [{"NAME"=>"Erica", "AGE"=>"12", "COLOR"=>"Opal"}, ...]
#
#   doc.to_json
#   #=> '[{"NAME":"Erica","AGE":"12","COLOR":"Opal"},...]'
#
#   doc.to_csv
#   #=> "NAME,AGE,COLOR\nErica,12,Opal\nAlex,23,Cyan\n..."
#
# @since 0.1.0
#
class Nodaire::Tablatal
  include Enumerable

  # @deprecated This will be removed in a future release. Use {#to_a} instead.
  # @return [Array<Hash>]
  attr_reader :data
  # @return [Array] the keys from the first line of the source.
  attr_reader :keys
  # @return [Array<String>] an array of zero or more error message strings.
  # @see #valid?
  # @since 0.2.0
  attr_reader :errors

  ##
  # Parse the document `source`.
  #
  # @example Read a Tablatal file
  #   source = File.read('example.tbtl')
  #
  #   doc = Nodaire::Tablatal.parse(source)
  #   puts doc.first['NAME']
  #
  # @example Read a Tablatal file and symbolize names
  #   source = File.read('example.tbtl')
  #
  #   doc = Nodaire::Tablatal.parse(source, symbolize_names: true)
  #   puts doc.first[:name]
  #
  # @param [String] source The document source to parse.
  # @param [Boolean] symbolize_names
  #   If `true`, normalize key names and convert them to lowercase symbols.
  #   If `false`, convert keys to uppercase strings.
  #
  # @return [Tablatal]
  # @since 0.2.0
  #
  def self.parse(source, symbolize_names: false)
    parser = Parser.new(source, false, symbolize_names: symbolize_names)

    new(parser)
  end

  ##
  # @deprecated This will be removed in a future release. Use {.parse} instead,
  #   and validate the result using {#valid?} and {#errors}.
  # @since 0.2.0
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
  # @since 0.2.0
  #
  def valid?
    @errors.empty?
  end

  ##
  # Returns the data for a given row `index`.
  #
  # @example
  #   doc = Nodaire::Tablatal.parse(source)
  #   puts doc[0]
  #
  # @return [Hash] the data for the given row `index`.
  #   If not found, returns `nil`.
  # @since 0.5.0
  #
  def [](index)
    @data[index]
  end

  ##
  # Returns the value for a given `key` in each row.
  #
  # If the `key` is not found, returns an empty array.
  #
  # @example
  #   doc.pluck('NAME')
  #   #=> ["Erica", "Alex", "Nike", "Ruca"]
  #
  # @return [Array<String>] the values for a given `key`.
  # @since UNRELEASED
  #
  def pluck(key)
    keys.include?(key) ? @data.map { |row| row[key] } : []
  end

  ##
  # Convert the document to an array of hashes.
  #
  # @return [Array<Hash>]
  #
  def to_a(*args)
    @data.to_a(*args)
  end

  ##
  # Convert the document to JSON.
  #
  # @return [String]
  # @since 0.5.0
  #
  def to_json(*args)
    @data.to_json(*args)
  end

  ##
  # Convert the document to CSV.
  #
  # @return [String]
  #
  def to_csv
    CSV.generate do |csv|
      csv << keys
      data.each do |row|
        csv << keys.map { |key| row[key] }
      end
    end
  end

  # Enumerable
  # @private
  def each(&block)
    @data.each(&block)
  end

  private

  def initialize(parser)
    @data = parser.data
    @keys = parser.keys
    @errors = parser.errors
  end
end
