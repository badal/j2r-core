#!/usr/bin/env ruby
# encoding: utf-8
#
# File: core.rb
# Created: 13 May 2014
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  # core methods for reporter and auditer
  module Core
    # version of core part
    VERSION = '1.0.0'
  end
end

# when not using gem
require_relative '../../../j2r-jaccess/lib/j2r/jaccess.rb'

require_relative 'core/recipes.rb'
require_relative 'core/reports.rb'
