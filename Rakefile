# frozen_string_literal: true

def bundle_install_required!(gem_name)
  warn "Failed to load #{gem_name}. Please run `bundle install`."
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

task default: %i[rubocop spec]
