#!/usr/bin/env ruby
# encoding: utf-8

# File: table.rb
# Created: 17/03/12
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  module Reports
    # methods for building cross and compare derived tables
    module TableBuilder
      # @param col_ref [String] column giving lines
      # @param col_blow [Object] column to blow up
      # @return [Table] cross table for these columns
      def cross_table(col_ref, col_blow)
        TableBuilder.cross_report(statistics(col_ref, col_blow), col_ref)
      end

      # @param col_ref [String] column giving lines
      # @param col_blow [String] column to blow up
      # @return [Hash] [val, val] => statistics
      def statistics(col_ref, col_blow)
        ref = col_index(col_ref)
        blow = col_index(col_blow)
        Hash.new(0).tap do |hash|
          @lines.each { |line| hash[[line[ref], line[blow]]] += 1 }
        end
      end

      # @param first_col [String] name of first column
      # @param hash [Hash] statistics to show
      # @return [Table] table build from the statistics hash
      def self.cross_report(hash, first_col = '')
        refs, cols = build_coordinates(hash)
        lines = refs.map do |line_ref|
          [line_ref] + cols.map { |col| hash[[line_ref, col]] }
        end
        columns = [first_col] + cols
        # noinspection RubyArgCount
        Table.new(columns, lines)
      end

      # @param param [Column] column for comparing values
      # @param value_out [Object] present value
      # @param value_in [Object] absent value
      # @return [Table] comparison table
      # @param [Array] identifications list of identifying fields
      def compare(identifications, param, value_out, value_in)
        indices = ([param] + identifications).map { |col| col_index(col) }
        lines = @lines.map { |line| line.values_at(*indices) }
        lines_kept = TableBuilder.compare_first(lines, value_out, value_in)
        hsh = {}
        lines_kept.each { |line| hsh[line] = true }
        lines = @lines.select { |line| hsh[line.values_at(*indices)] }
        # noinspection RubyArgCount
        Table.new(@columns, lines)
      end

      # @param hash [Hash] statistics hash
      # @return [[Array, Array]] coordinate names
      def self.build_coordinates(hash)
        keys = hash.keys
        refs = keys.map(&:first)
        cols = keys.map(&:last)
        [refs.uniq.sort, cols.uniq.sort]
      end

      # @param value_out [Object] present value in col 0
      # @param value_in [Object] absent value in col.0
      # @param lines [[Array, Array]] lines containing value_out, value_in
      # @return [Array] lines with value_in and not value_out
      def self.compare_first(lines, value_out, value_in) # rubocop:disable MethodLength
        lines_out = []
        lines_in = []
        lines.each do |line|
          case line.first
          when value_out
            lines_out << [value_in] + line.drop(1)
          when value_in
            lines_in << line
          else
            nil
          end
        end
        lines_in - lines_out
      end
    end
  end
end
