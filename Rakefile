require 'rubygems/tasks'
require 'rubocop/rake_task'
require 'yard'

task default: 'test'

desc 'Run acceptance tests (RSpec + Rubocop)'
task test: 'acceptance'

desc 'Run all RSpec test with coverage reporting'
task spec: 'rcov:all'

Gem::Tasks.new(build: { tar: true, zip: true }, sign: { checksum: true, pgp: false })

desc 'Execute rubocop -D'
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['-D'] # display cop name
end

YARD::Rake::YardocTask.new do |t|
  t.stats_options = ['--list-undoc']
end

desc 'Run acceptance tests (RSpec + Rubocop)'
task :acceptance do |_t|
  Rake::Task['spec'].invoke
  Rake::Task['rubocop'].invoke
end

namespace :rcov do
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:rspec) do |_t|
    ENV['COVERAGE'] = 'true'
  end

  desc 'Run RSpec to generate aggregated coverage'
  task :all do |_t|
    rm 'coverage/coverage.data' if File.exist?('coverage/coverage.data')
    Rake::Task['rcov:rspec'].invoke
  end
end
