#!/usr/bin/env ruby
# encoding: utf-8

# File: executive_report.rb
# Created: 04/06/2014
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  # build executive report
  module Dashboard
    # build the pdf executive report

    # @param [Path] dir directory to write the file in
    # @return [Path] file written
    # @param [Hash] mode connection mode
    def self.build(mode, dir)
      Audits.dashboard_file(mode, dir)
    end
  end
end

if __FILE__ == $PROGRAM_NAME

  path = J2R::Dashboard.build('exploitation', 'C:\Temp')
  J2R.open_file_command(path)

end
