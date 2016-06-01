require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec


desc "Run govuk-lint with similar params to CI"
task "lint" do
  sh "bundle exec govuk-lint-ruby --format clang spec lib"
end
