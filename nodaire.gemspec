# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'nodaire/base'

Gem::Specification.new do |s|
  s.name        = 'nodaire'
  s.version     = Nodaire::VERSION
  s.date        = Nodaire::DATE
  s.license     = 'MIT'

  s.summary     = 'Text file parsers.'
  s.description = 'Nodaire is a collection of text file parsers.'

  s.authors     = ['Liam Cooke']
  s.email       = 'nodaire@liamcooke.com'
  s.homepage    = 'https://liamcooke.com/code/nodaire/'
  s.metadata    = {
    # 'bug_tracker_uri' => '',
    'changelog_uri' => 'https://git.sr.ht/~ljc/nodaire/tree/main/CHANGELOG.md',
    'documentation_uri' => 'https://www.rubydoc.info/gems/nodaire',
    'homepage_uri' => 'https://liamcooke.com/code/nodaire/',
    'source_code_uri' => 'https://git.sr.ht/~ljc/nodaire',
  }

  s.required_ruby_version = '>= 2.5.0'

  s.files = Dir['lib/**/*.rb'] + [
    'LICENSE',
    'README.md',
  ]
end
