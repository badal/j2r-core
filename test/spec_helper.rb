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
  DATA = ENV['J2R_DATA']
end

require 'j2r/jaccess'
require_relative '../lib/j2r/core.rb'

require 'minitest/autorun'

include JacintheReports

Dir.glob('**/*_test.rb') { |f| require_relative f } if __FILE__ == $PROGRAM_NAME
