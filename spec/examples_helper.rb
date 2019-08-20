# frozen_string_literal: true

require 'json'

EXAMPLES_DIR = File.expand_path('examples', __dir__)

class ExampleReader
  def initialize
    @cache = {}
  end

  def [](filename)
    return cache[filename] if cache.include? filename

    data = read_file(filename)
    data = parse(data, File.extname(filename))

    cache[filename] = data
  end

  private

  attr_reader :cache

  def read_file(filename)
    File.read File.join(EXAMPLES_DIR, filename)
  end

  def parse(data, extname)
    case extname
    when '.json' then JSON.parse data
    else data
    end
  end
end
