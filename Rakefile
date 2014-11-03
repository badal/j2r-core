#!/usr/bin/env ruby
# encoding: utf-8

require 'yard'
require 'yard/rake/yardoc_task'
require 'rake/testtask'

require_relative 'lib/j2r/core/version.rb'

desc 'build gem file'
task :build_gem do
  system 'gem build j2r-core.gemspec'
  FileUtils.cp(Dir.glob('*.gem'), ENV['LOCAL_GEMS'])
end

YARD::Rake::YardocTask.new do |t|
  t.options += ['--title', "#{JacintheReports::Core::VERSION} Documentation"]
  t.options += %w(--files LICENSE)
  t.options += %w(--files HISTORY.md)
  t.options += %w(--files TODO.md)
  t.options += %w(--verbose)
end

desc 'show not documented'
task :yard_not_documented do
  system 'yard stats --list-undoc'
end

Rake::TestTask.new do |t|
  t.libs.push 'lib'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

desc 'build Manifest'
task :manifest do
  system ' mast -x bin -x metrics -x doc -x help -x coverage -x "documentation v1" * > MANIFEST'
end

import('metrics.rake')
