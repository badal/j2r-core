#!/usr/bin/env ruby
# encoding: utf-8

# File: recipe_spec.rb
# Created: 23/05/12
#
# (c) Michel Demazure <michel@demazure.com>

require_relative 'spec_helper.rb'

include Jaccess
include Recipes

describe 'Operations' do

  let(:list) { (1..5).to_a }

  it 'sum' do
    Operation.sum(list).must_equal 15
  end

  it 'mean' do
    Operation.mean(list).must_equal 3
  end

  it 'variance' do
    Operation.variance(list).must_equal 2
  end

  it 'standard_deviation' do
    Operation.standard_deviation(list).must_equal Math.sqrt(2)
  end

end
