#!/usr/bin/env ruby
# encoding: utf-8

# File: template.rb
# Created: 08/04/12
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  module Audits
    # Templates for auditer reports
    class Template
      # @param [Symbol] table database table
      # @param [Hash] columns  field => name
      def initialize(table, columns)
        @db_table = table
        @columns = columns
      end

      # @param [String] name basename of json file
      # @return [Template] new template
      def self.from_json_file(name)
        path = File.expand_path("#{name}.json", User.templates)
        json = File.read(path, encoding: 'utf-8')
        table, columns = *JSON.parse(json,
                                     symbolize_names: true,
                                     create_additions: false)
        new(table, columns)
      end

      # @return [Recipe] filtering recipe build from the template
      def recipe
        Recipes::Recipe.from_hash(db_table: @db_table,
                                  filters: [[:tiers_id, '*', true]],
                                  columns: @columns)
      end

      # @param [Integer] tiers_id id of tiers
      # @return [Table] table for report
      def table_for(tiers_id)
        Recipes::Runner.new(recipe, tiers_id: tiers_id).table_for_report
      end
    end
  end
end
