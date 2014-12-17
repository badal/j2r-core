#!/usr/bin/env ruby
# encoding: utf-8

# File: table.rb
# Created: 17/03/12
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  module Reports
    # Inside table of reports
    class Table
      include TableBuilder
      include TableFormatters

      # list of column names
      attr_accessor :columns
      attr_reader :lines

      # @param columns [Array] array of column names
      # @param lines [Array]  array of report lines
      def initialize(columns, lines)
        @columns = columns.map(&:to_s)
        @lines = lines.map { |line| line.map(&:to_s) }
      end

      # @return [Bool] test if table has columns
      def empty?
        @columns.empty?
      end

      # TODO: useless???
      # @param query [String] sql select query
      # @return [Table] new table
      # @param columns [Array] contains the colums in the good orders
      def self.from_sql(query, columns = nil)
        enum = Jaccess.base.fetch(query)
        from_enum(enum, columns)
      end

      # @param enum [Enumerator] sequel enumerator
      # @return [Table] new table
      # @param columns [Array] contains the colums in the good orders
      def self.from_enum(enum, columns = nil)
        columns ||= enum.columns
        from_hashes(enum, columns)
      end

      # @param hashes [Array<Hash>] hashes of results to report
      # @param columns [Array] the colums in the good orders
      # @return [Table] new table
      def self.from_hashes(hashes, columns)
        lines = hashes.map do |hhhh|
          columns.map { |col| hhhh[col.to_sym] }
        end
        new(columns, lines)
      end

      # @param [Hash] columns field => name
      # @return [Table] table with extracted columns in the good order
      def extract(columns)
        indices = columns.keys.map { |col| col_index(col) }
        lines = @lines.map { |line| line.values_at(*indices) }
        self.class.new(columns.values, lines)
      end

      # @return [Integer] number of lines
      def size
        @lines.size
      end

      # @return [String] number of lines for printing
      def size_to_print
        table_size = size
        table_size > 1 ? "#{table_size} lignes" : "#{table_size} ligne"
      end

      # @param col [String, to_s] column name
      # @return [Integer] index of given column
      def col_index(col)
        @columns.index(col.to_s)
      end

      # @param col [String, #to_s] name of column
      # @return [Array] this column content
      def full_column(col)
        indx = col_index(col)
        return [] unless indx
        @lines.map { |line| line[indx] }
      end

      # @param col [String, #to_s] name of column
      # @return [Array] array of all possible values
      def all_values(col)
        list = full_column(col)
        list.uniq.sort_by(&:downcase_without_accents)
      end

      # @return [Array<Integer>] array of all tiers_id
      def all_tiers
        indx = col_index(:tiers_id)
        return [] unless indx
        @lines.map { |line| line[indx] }.uniq
      end

      # @param lim [Integer] number of lines to keep
      # @return [Table] shortened table
      def take(lim)
        Table.new(@columns, @lines.take(lim))
      end

      # @param lim [Integer] number of lines to keep
      # @return [Table] sampled table
      def sample_for_html(lim)
        indices = size.times.to_a.sample(lim).sort
        lines = @lines.values_at(*indices)
        Table.new(@columns, lines).doc_for_html
      end

      # @param array [Array]
      # @param indx [Integer]
      # @return [Array] dup of given array with item at index indx removed
      def self.remove(array, indx)
        arr = array.dup
        arr.delete_at(indx)
        arr
      end

      # @param col [String, to_s] column to delete
      # @return [Table] table with the given column deleted
      def delete_col(col)
        indx = col_index(col)
        lines = @lines.map do |line|
          line.dup.tap { |arr| arr.delete_at(indx) }
        end
        columns = @columns.dup.tap { |arr| arr.delete_at(indx) }
        Table.new(columns, lines)
      end

      # @param col [String, #to_s] name of column
      # @param value [String or Regexp] value
      # @return [table] table reduced to lines where column match value
      def match(col, value)
        indx = col_index(col)
        filtered_lines = @lines.select { |line| line[indx].match(value) }
        Table.new(@columns, filtered_lines)
      end

      # @param col [String, to_s] column to split
      # @return [Hash] value in column => partial table
      def split(col)
        {}.tap do |hash|
          all_values(col).each do |value|
            rep = match(col, Regexp.new("^#{value}$"))
            hash[value] = rep.delete_col(col)
          end
        end
      end
    end
  end
end
