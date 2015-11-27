#!/usr/bin/env ruby
# encoding: utf-8

# File: query_builder_spec.rb
# Created: 22/05/12
#
# (c) Michel Demazure <michel@demazure.com>

require_relative 'spec_helper.rb'

include Jaccess
include Recipes

describe 'QueryBuilder' do
  before { J2R.jaccess('test') }
  let(:builder) do
    table = :abonnement
    filter_table = { abonnement_annee: ['2011', true], revue_nom: ['Mémoires', false] }
    QueryBuilder.new(table, filter_table, {})
  end

  describe 'maketree' do
    it 'make_tree' do
      (->() { builder.make_tree([:abonnement_type, :tiers_nom]) }).must_be_silent
    end
  end

  describe 'building query' do
    it 'without parameters' do
      query = "SELECT `tiers_nom` FROM `abonnement` INNER JOIN `revue` AS `abonnement_revue` ON (`abonnement_revue`.`revue_id` = `abonnement`.`abonnement_revue`) INNER JOIN `client_sage` AS `abonnement_client_sage` ON (`abonnement_client_sage`.`client_sage_id` = `abonnement`.`abonnement_client_sage`) INNER JOIN `tiers` AS `client_sage_client_final` ON (`client_sage_client_final`.`tiers_id` = `abonnement_client_sage`.`client_sage_client_final`) WHERE ((`abonnement_annee` NOT IN ('2011', 1)) AND (`revue_nom` NOT IN ('M\u00E9moires', 0)))"
      fields = [:tiers_nom]
      builder.build_query_with(fields).must_equal query
    end
  end
end
