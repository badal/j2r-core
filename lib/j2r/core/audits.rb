#!/usr/bin/env ruby
# encoding: utf-8

# File: audits.rb
# Created: 23/05/2014
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  # methods for auditer
  module Audits
    # this year
    YEAR = Time.now.strftime('%Y').to_i
  end
end

require_relative 'audits/snippets.rb'
require_relative 'audits/template.rb'
require_relative 'audits/tiers_auditor.rb'
require_relative 'audits/tiers_searcher.rb'
