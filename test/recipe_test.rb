#!/usr/bin/env ruby
# encoding: utf-8

# File: recipe_spec.rb
# Created: 23/05/12
#
# (c) Michel Demazure <michel@demazure.com>

require_relative 'spec_helper.rb'

include Jaccess
include Recipes

describe 'Recipe' do
  before { J2R.jaccess('test') }
  let(:recipe) do
    table = :abonnement
    filters = [[:abonnement_type, '1', true], [:revue_nom, '*', true]]
    Recipes::Recipe.from_hash(db_table: table, filters: filters)
  end
  let(:runner) { Runner.new(recipe) }

  describe 'to and from' do
    it 'hash' do
      hsh = recipe.to_hash
      Recipe.from_hash(hsh).to_hash.must_equal(hsh)
    end
    it 'yaml' do
      yml = recipe.to_yaml
      Recipe.from_yaml(yml).to_yaml.must_equal(yml)
    end
  end

  describe 'initial run' do
    it 'without parameters' do
      table = runner.run([:tiers_id])
      table.size.must_equal(11_953)
      table.doc_for_txt[120].must_equal('|213     |')
    end
  end

  describe 'adding extra fields' do
    it 'without parameters' do
      recipe.add_extra_fields([:abonnement_annee])
      table = runner.run([:tiers_id])
      table.size.must_equal(11_953)
      table.doc_for_txt[120].must_equal('|2010            |213     |')
    end
  end

  describe 'adding macro' do
    it 'without parameters' do
      recipe.add_extra_fields([:abonnement_annee])
      runner.run([:tiers_id])
      args = [:compare, [:tiers_id], :abonnement_annee, '2010', '2009']
      table = recipe.do_and_add(*args)
      table.size.must_equal(117)
    end
  end

  describe 'possible_values' do
    it('') { recipe.possible_values(:abonnement_annee).must_equal(%w(2009 2010 2011 2012)) }
  end
end
