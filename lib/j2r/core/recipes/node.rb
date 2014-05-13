#!/usr/bin/env ruby
# encoding: utf-8

# File: node.rb
# Created: 28/01/12
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  module Recipes
    # nodes of joining trees
    class Node
      attr_reader :id, :table, :links, :alias

      # @param father [node] father of node
      # @param id [Symbol] identifier field of table
      # @param table [Symbol] database table of the node
      # @param table_alias [String or Symbol] [Facultative] initial alias for the node
      def initialize(father, id, table, table_alias = table)
        @id = id
        @table = table
        @links = {}
        @alias = table_alias
        @father = father
      end

      # @return [Node] obtained by joining thru +join+
      # @param join [Symbol] field for joining
      def link_node(join)
        target, target_id = Jaccess::Model.joining_table[[@table, join]]
        return nil unless target
        node = Node.new(self, target_id, target, "#{@alias_}#{join}".to_sym)
        @links[join] = node
        node
      end

      # @param field [Symbol or String] field to qualify
      # @return [Symbol] field, qualified with node alias and field alias
      def fully_qualified(field)
        "#{@alias__}#{field}".to_sym
      end

      # initialize traversal
      def reset
        @remaining_links = @links.keys
      end

      # if remaining_links is empty, return father,
      # else, yield the first remaining link to the block, clear it and return the linked node
      def traverse
        link = @remaining_links.first
        if link
          @remaining_links.shift
          yield link
          @links[link]
        else
          @father
        end
      end
    end # class Node
  end
end
