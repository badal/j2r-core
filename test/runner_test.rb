#!/usr/bin/env ruby
# encoding: utf-8
#
# File: runner_spec.rb
# Created: 15/02/12
#
# (c) Michel Demazure <michel@demazure.com>

require_relative 'spec_helper.rb'

include Jaccess
include Recipes

describe 'Runner' do

  before { J2R.jaccess('test') }
  let(:runner) do
    table = :abonnement
    filters = [[:abonnement_annee, '2011', true], [:revue_nom, '*', true]]
    Runner.new(Recipes::Recipe.from_hash(db_table: table, filters: filters))
  end

  it 'split works' do
    report = runner.run([:revue_nom])
    sizes = { 'Annales de l\'ENS' => 226,
              'Astérisque' => 235,
              'Bulletin' => 678,
              'Gazette des mathématiciens' => 2145,
              'Mémoires' => 285,
              'Panoramas et synthèses' => 134,
              'Revue d\'Histoire des mathématiques' => 477,
              'Séminaires et Congrès' => 63 }
    report.split(:revue_nom).map { |key, table| [key, table.size] }.must_equal(sizes.to_a)
  end

  it 'parametrize works' do
    runner.parameter_values = { revue_nom: 'Bulletin' }
    report = runner.run([])
    report.size.must_equal(678)
  end

  let(:runner_with_parameters) do
    table = :abonnement
    filters = [[:abonnement_type, '1', true], [:revue_nom, '*', true]]
    recipe = Recipes::Recipe.from_hash(db_table: table, filters: filters)
    parameter_values = { revue_nom: 'Mémoires' }
    Runner.new(recipe, parameter_values)
  end

  it 'with parameters' do
    table = runner_with_parameters.run([:tiers_id])
    table.size.must_equal(1034)
    table.doc_for_txt[120].must_equal('|6162    |')
  end

end
