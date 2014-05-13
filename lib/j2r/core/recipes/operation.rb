#!/usr/bin/env ruby
# encoding: utf-8

# File: operation.rb
# Created: 11/07/13
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  module Recipes
    # aggregation operations on report columns
    class Operation
      # array of all operations names
      NAMES = %w(Somme Moyenne Variance Ecart-type)
      # array of printing formats
      FORMATS = %w(%g %2.f %g %.2f)
      # array of methods to be called
      METHODS = [:sum, :mean, :variance, :standard_deviation]

      # @param [Array] list a column
      # @return [Float] sum of column
      def self.sum(list)
        list.reduce(0.0) { |acc, val| acc + val.to_f } # Somme
      end

      # @param [Array] list a column
      # @return [Float] mean of column
      def self.mean(list)
        sum(list) / list.size
      end

      # @param [Array] list a column
      # @return [Float] variance of column
      def self.variance(list)
        squares = list.map { |val| (val.to_f)**2 }
        mean(squares) - mean(list)**2
      end

      # @param [Array] list a column
      # @return [Float] standard deviation of column
      def self.standard_deviation(list)
        include Math
        Math.sqrt(variance(list))
      end

      attr_reader :field
      # @param [Symbol] field field in table
      # @param [Integer] indx index of operation in +OPERATIONS+
      def initialize(field, indx)
        @field = field
        @index = indx
      end

      # @param [Array] list a column
      # @return [String] formatted result of operation on column
      def operate(list)
        res = Operation.send(METHODS[@index], list)
        format(FORMATS[@index], res)
      end

      # @param [Table] table tabel to be acted on
      # @return [String] formatted result of operation on column
      def act_on(table)
        operate(table.full_column(@field))
      end

      # @return [String] full name of operation
      def name
        "#{@field} => #{NAMES[@index]}"
      end
    end
  end
end

__END__


  def self.list_operation(list, indx)
    return unless indx == 0
    list.reduce(0.0) { |acc, val| acc + val.to_f } # Somme
  end


  # To change this template use File | Settings | File Templates.
end

end
end
