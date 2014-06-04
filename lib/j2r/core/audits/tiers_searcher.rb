#!/usr/bin/env ruby
# encoding: utf-8

# File: tiers_searcher.rb
# Created: 08/04/12
#
# (c) Michel Demazure <michel@demazure.com>

require_relative 'snippets.rb'
require_relative 'template.rb'
require_relative 'tiers_auditor.rb'

module JacintheReports
  module Audits
    # searcher called by the auditer gui
    class TiersSearcher
      SOURCE = Recipes::Runner.from_hash(db_table: :tiers)
      FIELDS = [:tiers_nom, :tiers_prenom, :tiers_id]

      private_constant :SOURCE, :FIELDS

      # @return [Array<Array>] list of triples [id, name, normalized name] for all tiers
      def self.full_list
        hashes = SOURCE.build_enum(FIELDS)
        hashes.map do |hsh|
          name = hsh[:tiers_nom] + ' ' + (hsh[:tiers_prenom] || '')
          name_sa = name.downcase_without_accents
          [hsh[:tiers_id], name, name_sa]
        end
      end

      # @return [TiersSearcher] a new instance
      def initialize
        @selection_list = self.class.full_list.sort_by(&:last).uniq(&:first)
      end

      # @param [String] text given pattern
      # @return [Array<String>] list of filtered full names
      def search(text)
        number = text.to_i
        if number != 0
          search_by_number(number)
        else
          search_by_pattern(text)
        end
      end

      # @param [String] text given pattern
      # @return [Array<String>] list of filtered full names
      def search_by_pattern(text)
        pattern = Regexp.new(text.downcase.without_accents.gsub('*', '.*'))
        @selection_list.select { |item| pattern =~ item.last }
      end

      # @param [Integer] number
      # @return [Array<String>] list with selected tiers as unique element
      def search_by_number(number)
        @selection_list.select { |item| item.first == number }
      end

      # open the audit report
      # @param [Integer] tiers_id id of tiers
      def show_audit(tiers_id)
        path = Audits::TiersAuditor.new(tiers_id).audit_path
        J2R.open_file_command(path)
      end

      # @param [Integer] tiers_id id of tiers
      # @return [String] html report extract to be shown
      def extract(tiers_id)
        Audits::TiersAuditor.new(tiers_id).extract
      end
    end
  end
end
