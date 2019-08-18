# frozen_string_literal: true

def bundle_install_required!(gem_name)
  warn "Failed to load #{gem_name}. Please run `bundle install`."
end

task default: %i[rubocop spec yard]

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

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.stats_options = ['--list-undoc']
  end
rescue LoadError
  bundle_install_required! 'yard'
end
