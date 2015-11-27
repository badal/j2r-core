#!/usr/bin/env ruby
# encoding: utf-8

# File: new_query_builder_saved.rb
# Created: 16/02/12, totally rebuilt : 25/03/12, again 22/05/12
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  module Recipes
    # square character
    SQUARE = "\u25fb"
    # build queries from filters and sorts
    class QueryBuilder
      # @param table [Symbol] table of considered node
      # @param list [Array] list of fields
      # @return [Hash] keys are fields to link, values are fields to add under the key link
      def self.extract_links(table, list)
        paths = list.map { |field| Jaccess::Model.extended_fields[[table, field]] }.compact
        {}.tap do |hash|
          paths.each { |path| (hash[path.first] ||= []) << path.last }
        end
      end

      # @param step [Symbol] field to link
      # @param table [Symbol] table to link from
      # @return [Symbol] table for this new link
      def self.step_table(step, table)
        Jaccess::Model.extended_joins.map do |(source, target), path|
          target if source == table && path[1] == step
        end.compact.first
      end

      # @param [Symbol] db_table JacintheDB table
      # @param [Array<Array>] filters [[field, value, bool],...]
      # @param [Hash] sorts field => boolean
      def initialize(db_table, filters, sorts)
        @db_table = db_table.to_sym
        @filters = filters
        @sorts = sorts
      end

      # @return [Tree] joining tree built with these fields
      # @param [Array] fields list of fields
      def make_tree(fields = [])
        fields = (@filters.map(&:first) + @sorts.keys + fields).uniq
        @nodes = {}
        # noinspection RubyArgCount
        head = Node.new(nil, nil, @db_table)
        @nodes[@db_table] = head
        build_link_nodes(@db_table, fields)
        Tree.new(@nodes.values, head)
      end

      # @return [SQL] SQL query
      # @param [Array] fields list of fields
      def build_query_with(fields)
        query = make_tree(fields).build_sequel
        @filters.each do |field, value, bool|
          value = nil if value == SQUARE
          query = bool ? query.filter(field => value) : query.filter(Sequel.~({ field => value }))
        end
        @sorts.each_pair.map do |field, bool|
          query = query.order_append(bool ? field : Sequel.desc(field))
        end
        query.select(*fields).sql
      end

      private

      # @param table [Symbol] database table of the considered node
      # @param fields [Array<Symbol>] list of fields
      # build the necessary nodes under this table to access the given fields
      def build_link_nodes(table, fields)
        hsh = QueryBuilder.extract_links(table, fields)
        hsh.each_pair.map do |(step, fields_under)|
          step_table = QueryBuilder.step_table(step, table)
          @nodes[step_table] = @nodes[table].link_node(step.to_sym)
          build_link_nodes(step_table, fields_under)
        end
      end
    end
  end
end
