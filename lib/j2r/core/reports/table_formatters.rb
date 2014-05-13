#!/usr/bin/env ruby
# encoding: utf-8

# File: table_formatters.rb
# Created: 17/03/12
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  module Reports
    # formatters methods for class Table
    module TableFormatters
      # vertical character
      VERT = '|'
      # horizontal character
      HORIZ = '-'
      # html format for tables
      TABLE_FORMAT =
          '<table rules=all cellpadding=2\
 style="border-color:#00CCFF;border-width:4;border-style:groove">'

      # @return [String] doc for prawn
      def doc_for_pdf
        [@columns.map { |title| "<b><i>#{title}</i></b>" }] + @lines
      end

      # @return [Array<String>] console output
      def doc_for_txt
        horiz = HORIZ * horiz_length
        [horiz, line_format(@columns), horiz] +
            @lines.map { |line| line_format(line) } + [horiz]
      end

      # @return [String] csv output
      def csv_output
        ([@columns] + @lines).map { |line| TableFormatters.csv_line(line) }.join("\n")
      end

      # @return [String] html output
      def doc_for_html
        TABLE_FORMAT + "\n" +
            TableFormatters.html_line(@columns, 'th') +
            @lines.map { |line| TableFormatters.html_line(line) }.join +
            "\n</table>"
      end

      private

      def build_widths
        (first_line_widths + line_widths).transpose.map(&:max)
      end

      def first_line_widths
        [@columns.map(&:size)]
      end

      def line_widths
        @lines.map do |line|
          line.map { |item| item ? item.size : 0 }
        end
      end

      def widths
        @widths ||= build_widths
      end

      def line_format(line)
        VERT + pad(line).join(VERT) + VERT
      end

      def pad(line)
        line.zip(widths).map { |item, width| item.to_s.ljust(width) }
      end

      def horiz_length
        widths.reduce(&:+) + @columns.size + 1
      end

      def self.html_line(line, tag = 'td')
        "<tr>\n" +
            line.map { |item| "<#{tag}>#{item}</#{tag}>" }.join("\n") +
            "\n</tr>\n"
      end

      # @return [String] converted line
      # @param line [Array] line to convert
      def self.csv_line(line)
        line.map do |val|
          "#{val.force_encoding('utf-8')}"
        end.join(J2R::CSV_SEPARATOR)
      end
    end
  end
end

__END__
