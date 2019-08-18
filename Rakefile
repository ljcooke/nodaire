# frozen_string_literal: true

def bundle_install_required!(gem_name)
  warn "Failed to load #{gem_name}. Please run `bundle install`."
end

begin
  require 'rdoc/task'
  RDoc::Task.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.main = 'doc/Home.md'
    rdoc.rdoc_files.include('doc/Home.md', 'lib/**/*.rb')
    rdoc.options << '--all'
  end
rescue LoadError
  bundle_install_required! 'rdoc'
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  bundle_install_required! 'rspec'
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  bundle_install_required! 'rubocop'
end

task default: %i[rubocop spec rerdoc]
