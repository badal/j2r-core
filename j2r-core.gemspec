# encoding: utf-8

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)

require 'lib/j2r/core/version'

Gem::Specification.new do |s|
  s.name = 'j2r-core'
  s.version = JacintheReports::Core::VERSION
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.summary = 'To be replaced'
  s.description = 'To be replaced'
  s.author = 'Michel Demazure'
  s.email = 'michel@demazure.com'
  s.homepage = 'http://github.com/badal/j2r-core'
  s.add_dependency('j2r-jaccess')
  s.add_dependency('prawn', '=0.14')
  s.files = %w(LICENSE README.md HISTORY.md MANIFEST Rakefile) + Dir.glob('{lib,test}/**/*')
  s.require_path = 'lib'
end
