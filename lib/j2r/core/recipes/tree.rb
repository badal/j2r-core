#!/usr/bin/env ruby
# encoding: utf-8

# File: tree.rb
# Created: 28/01/12
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  # module of report creation
  module Recipes
    # joining tree for constructing sql queries
    class Tree
      # @param list [Array<Node>] list of nodes
      # @param head_node [Node] head node
      def initialize(list, head_node)
        @list = list
        @head = head_node
      end

      # @return [Sequel::Dataset] Sequel embedding of sql request giving anwwer
      def build_sequel
        set_starting_state
        node = @head
        node = node.traverse { |link| join_step(node, link) } while node
        @source
      end

      # initialize source and processing list of links
      def set_starting_state
        @source = Jaccess[@head.table]
        @list.each { |node| node.reset }
      end

      # join step of processind
      # @param node [Node] node to link
      # @param link [Link] link to be joined and filtered
      def join_step(node, link)
        next_node = node.links[link]
        @source = @source.join_table(:inner, next_node.table, { next_node.id => link },
                                     table_alias: next_node.alias, implicit_qualifier: node.alias)
      end
    end
  end
end
