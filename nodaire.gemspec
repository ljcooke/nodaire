# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'nodaire/version'

Gem::Specification.new do |s|
  s.name        = 'nodaire'
  s.version     = Nodaire::VERSION
  s.date        = Nodaire::DATE
  s.license     = 'MIT'

  s.summary     = 'Text file parsers.'
  s.description = 'Nodaire is a collection of text file parsers.'

  s.authors     = ['Liam Cooke']
  s.email       = 'nodaire@liamcooke.com'
  s.homepage    = 'https://github.com/ljcooke/nodaire'
  s.metadata    = {
    'bug_tracker_uri' => 'https://github.com/ljcooke/nodaire/issues',
    'changelog_uri' => 'https://github.com/ljcooke/nodaire/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/ljcooke/nodaire',
    'homepage_uri' => 'https://github.com/ljcooke/nodaire',
    'source_code_uri' => 'https://github.com/ljcooke/nodaire',
  }

  s.files = [
    'LICENSE',
    'README.md',
    Dir['lib/**/*.rb'],
  ].flatten
end