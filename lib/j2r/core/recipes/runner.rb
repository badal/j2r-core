#!/usr/bin/env ruby
# encoding: utf-8

# File: runner.rb
# Created: 23/05/12
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  # methods and classes for recipes and runners
  module Recipes
    # character for jokers
    JOKER = '*'

    # to carry and process recipes with parameter values
    class Runner
      # @param [Hash] hsh hash of recipe data
      # @return [Runner] a new recipe with this recipe
      def self.from_hash(hsh)
        new(Recipes::Recipe.from_hash(hsh))
      end

      attr_accessor :parameter_values, :operations

      # @param [Hash] parameter_values : parameter => value
      # @param [Recipe] recipe recipe to parametrize
      def initialize(recipe, parameter_values = {})
        @recipe = recipe
        @parameter_values = parameter_values
        @operations = []
      end

      # set and return the internal table
      # @return [Table] table resulting of recipe
      # @param [Array] fields list of fields for table column
      def run(fields = [])
        @recipe.internal_table = build_table(fields)
      end

      # @return [Table] table resulting of recipe
      # @param [Array] fields list of fields for table column
      def build_table(fields)
        enum = build_enum(fields)
        table = Reports::Table.from_enum(enum)
        @recipe.act(table)
      end

      # @return [Sequel enumerator] enumerator for table lines
      # @param [Array] fields list of fields for table columns
      def build_enum(fields)
        total_fields = (@recipe.extra_fields + fields).uniq
        query_builder = QueryBuilder.new(@recipe.db_table, true_filters, @recipe.sorts)
        query = query_builder.build_query_with(total_fields)
        Jaccess.base.fetch(query)
      end

      # @return [Table] internal table reduced to recipe columns
      def table_extracted
        @recipe.internal_table.extract(@recipe.columns)
      end

      # @return [Table] table for the report
      def table_for_report
        run(@recipe.columns.keys)
        if @operations.empty?
          table_extracted
        else
          table_operated
        end
      end

      # @return [Hash(Table)|Table] table(s) for the report
      # @param [String] col name of column (not field) to be blowned up
      def table_for_bundle(col)
        run(@recipe.columns.keys)
        if @operations.empty?
          table_extracted.split(col)
        else
          table_split_operated(col)
        end
      end

      # @return [Table] result cross table for the report
      # @param [String] col name of column (not field) to be blowned up
      def table_split_operated(col)
        tables = table_split_by(col)
        lines = tables.each_pair.map do |name, tbl|
          [name] + @operations.map { |oper| oper.act_on(tbl) }
        end
        Reports::Table.new([''] + @operations.map(&:name), lines)
      end

      # @return [Array] internal table split by this column
      # @param [String] col name of column (not field) to be blowned up
      def table_split_by(col)
        field = @recipe.columns.invert[col]
        @recipe.internal_table.split(field)
      end

      # @return [Table] operation result formatted for the report
      def table_operated
        table = @recipe.internal_table
        cols = ['', 'Opération', 'Résultat']
        lines = @operations.map do |oper|
          field_name = @recipe.columns[oper.field]
          [field_name, oper.name, oper.act_on(table)]
        end
        Reports::Table.new(cols, lines)
      end

      # @return [Hash] filters taking parametrization in account
      def true_filters
        true_filters = @recipe.filters.dup
        @parameter_values.each_pair do |field, value|
          @recipe.filters.each do |fil_field, fil_val, bool|
            next unless field == fil_field && fil_val == JOKER
            true_filters << [field, value, bool]
          end
        end
        true_filters.reject { |_, value, _| value == JOKER }
      end

      # @return [Array<Integer>] list of id's' of all occuring tiers
      def tiers_list
        build_table([:tiers_id]).all_tiers
      rescue Sequel::DatabaseError # no tiers !
        nil
      end
    end
  end
end
