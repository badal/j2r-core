#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems/package_task'
require 'yard'
require 'yard/rake/yardoc_task'
require 'rake/testtask'
# require "cucumber/rake/task"

require_relative 'lib/j2r/core.rb'

spec = Gem::Specification.new do |s|
  s.name = 'j2r-core'
  s.version = J2R::Core::VERSION
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.summary = 'To be replaced'
  s.description = 'To be replaced'
  s.author = 'Michel Demazure'
  s.email = 'michel@demazure.com'
  # s.executables = ['your_executable_here']
  s.files = %w(LICENSE README.md HISTORY.md MANIFEST Rakefile) + Dir.glob('{bin,lib,test}/**/*')
  s.require_path = 'lib'
  s.bindir = 'bin'
end

Gem::PackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = false
 # p.need_zip = true
end

YARD::Rake::YardocTask.new do |t|
  t.options += ['--title', "J2R::Core::VERSION} Documentation"]
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

# Cucumber::Rake::Task.new do |task|
#  task.cucumber_opts = ["features"]
# end

import('metrics.rake')
