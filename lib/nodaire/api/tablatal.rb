# frozen_string_literal: true

require 'csv'

require_relative '../parsers/tablatal_parser'

##
# Interface for documents in _Tablatal_ format.
#
# _Tablatal_ is a 'list-type database format' by Devine Lu Linvega.
# See: https://wiki.xxiivv.com/#tablatal
#
#   require 'nodaire/tablatal'
#
#   doc = Nodaire::Tablatal.parse! <<~TBTL
#     NAME    AGE   COLOR
#     Erica   12    Opal
#     Alex    23    Cyan
#     Nike    34    Red
#     Ruca    45    Grey
#   TBTL
#
#   doc.valid?    # true
#   doc.keys      # ["NAME", "AGE", "COLOR"]
#   doc.to_a.last # {"NAME"=>"Ruca", "AGE"=>"45", "COLOR"=>"Grey"}
#   doc.to_csv    # "NAME,AGE,COLOR\nErica,12,Opal\nAlex,23,..."
#
# @since 0.1.0
#
class Nodaire::Tablatal
  # An array of hashes containing the data parsed from the source.
  # @return [Array<Hash>]
  attr_reader :data
  # An array of keys parsed from the source header line.
  # @return [Array]
  attr_reader :keys
  # An array of error message strings.
  # @since 0.2.0
  # @return [Array<String>]
  attr_reader :errors

  alias_method :to_a, :data

  ##
  # Parse the document +source+.
  #
  # @param [String] source The document source to parse.
  # @param [Boolean] symbolize_names
  #   If true, normalize key names and convert them to lowercase symbols.
  #
  # @since 0.2.0
  # @return [Tablatal]
  #
  def self.parse(source, symbolize_names: false)
    parser = Parser.new(source, false, symbolize_names: symbolize_names)

    new(parser)
  end

  ##
  # Parse the document +source+, raising an exception if a parser error occurs.
  #
  # @param [String] source The document source to parse.
  # @param [Boolean] symbolize_names
  #   If true, normalize key names and convert them to lowercase symbols.
  #
  # @since 0.2.0
  # @raise [ParserError]
  # @return [Tablatal]
  #
  def self.parse!(source, symbolize_names: false)
    parser = Parser.new(source, true, symbolize_names: symbolize_names)

    new(parser)
  end

  ##
  # A boolean indicating whether the source was parsed without errors.
  #
  # @since 0.2.0
  # @return [Boolean]
  #
  def valid?
    @errors.empty?
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

  private

  def initialize(parser)
    @data = parser.data
    @keys = parser.keys
    @errors = parser.errors
  end
end
