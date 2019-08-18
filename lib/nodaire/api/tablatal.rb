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
class Nodaire::Tablatal
  # An array of hashes containing the data parsed from the source.
  attr_reader :data
  # An array of keys parsed from the source header line.
  attr_reader :keys
  # An array of error message strings.
  attr_reader :errors

  alias_method :to_a, :data

  ##
  # Parse the document +source+ and return a Tablatal instance.
  # Ignores or attempts to work around errors.
  #
  # If +symbolize_names+ is +true+, normalizes keys and converts them
  # to lowercase symbols.
  #
  def self.parse(source, symbolize_keys: false)
    parser = Parser.new(source, false, symbolize_keys: symbolize_keys)

    new(parser)
  end

  ##
  # Parse the document +source+ and return a Tablatal instance.
  # Raises an exception if there are errors.
  #
  # If +symbolize_names+ is +true+, normalizes keys and converts them
  # to lowercase symbols.
  #
  def self.parse!(source, symbolize_keys: false)
    parser = Parser.new(source, true, symbolize_keys: symbolize_keys)

    new(parser)
  end

  ##
  # A boolean indicating whether the source was parsed without errors.
  #
  def valid?
    @errors.empty?
  end

  ##
  # Convert the document to CSV. Returns a string.
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
