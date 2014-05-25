#!/usr/bin/env ruby
# encoding: utf-8
#
# File: spec_helper.rb
# Created: 13 May 2014
#
# (c) Michel Demazure <michel@demazure.com>

# GUIs for Jacinthe
module JacintheReports
  # data directory
  DATA = ENV["J2R_DATA"]
end

require_relative '../lib/j2r/core.rb'

require 'minitest/spec'
# require 'minitest/reporters'
require 'minitest/autorun'

include J2R

if __FILE__ == $PROGRAM_NAME

  Dir.glob('**/*_spec.rb') { |f| require_relative f }

end
