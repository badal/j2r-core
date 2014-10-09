#!/usr/bin/env ruby
# encoding: utf-8

# File: dashboard.rb
# Created: 15/02/12
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  # diverse auditing methods
  module Audits
    # number of previous years to show
    BACK = 2

    # @return [String] formatted day now
    def self.day
      Time.now.strftime('%d-%m-%Y')
    end

    # class for year comparison statistics
    class Numbers < Array
      # types of items
      TYPES = [nil, 'Papier', '  Elec.']

      # @param year [Integer] year to be considered
      # @return [Array]array of ids of tiers members for this year
      def self.members_for(year)
        adhesions = J2R::AdhesionLocale.extended_join(:tiers)
        adhesions.where(adhesion_locale_annee: "#{year}",
                        adhesion_locale_ignorer: 0).map(:tiers_id).uniq
      end

      # @param journal [Integer] id of journal
      # @param type [Integer] id of subscription type
      # @param year [Integer] year to be considered
      # @return [Numbers] array of subscriber ids
      def self.subscribers_for(journal, type, year)
        abonnements = J2R::Abonnement.extended_join(:tiers)
        # noinspection RubyArgCount
        abonnements.filter(abonnement_annee: "#{year}",
                           abonnement_revue: "#{journal}",
                           abonnement_type: "#{type}",
                           abonnement_ignorer: 0)
        .filter(Sequel.~(client_sage_paiement_chez: 77)).map(:tiers_id).uniq
      end

      # @return [Numbers] array of yearly arrays of members
      def self.members
        new { |year| members_for(year) }
      end

      # @return [Numbers] array of yearly arrays of subscribers
      # @param journal [Integer] id of journal
      # @param type [Integer] id of subscription type
      def self.subscribers(journal, type)
        new { |year| subscribers_for(journal, type, year) }
      end

      # @return [Array] subtitles for report
      def self.subtitles
        %w(Totaux) + %w(Perdus Gardés Gagnés Totaux) * BACK
      end

      # @return [Array] titles for report
      def self.titles
        start = YEAR - BACK + 1
        ttl = BACK.times.reduce([(start - 1).to_s]) do |list, dly|
          year = start + dly
          list + ["#{year - 2001}-#{(year - 2000)}"] * 3 + [(year).to_s]
        end
        ['Effectifs (tiers)', 'Type'] + ttl
      end

      # @return [Array<Array>] subscription lines of report
      def self.subscription_table
        (1..20).to_a.map do |indx|
          journal = J2R::Revue[indx]
          method_name(indx, journal) if journal
        end.flatten(1).compact
      end

      # @param [Integer] indx id of record
      # @param [Sequel] journal record of 'revue' table
      # @return [Array] one oe two lines of subscription report
      def self.method_name(indx, journal)
        [1, 2].map do |type|
          content = Numbers.subscribers(indx, type).bilan
          next if content.all? { |val| val == 0 }
          [journal.revue_nom, TYPES[type]] + content
        end
      end

      # @return [Array] all lines of report
      def self.content_table
        [['', ''] + Numbers.subtitles] +
            [['Adhésions', ''] + Numbers.members.bilan] +
            subscription_table
      end

      # @return [Report] board report
      def self.dashboard
        Reports::Report.new(Reports::Table.new(titles, content_table))
      end

      # @return [Numbers] new (yields to the block)
      # @param [Proc] block proc to build the numbers 'number = proc(year)'
      def initialize(&block)
        numbers = (0..BACK).map { |diff| block.call(YEAR - diff) }
        super(numbers)
      end

      # @param delay [Integer] backwards delay of year
      # @return [Integer] total number of tiers
      def total(delay)
        self[delay].size
      end

      # @param delay [Integer] backwards delay of year
      # @return [Integer] number of acquired tiers
      def acquired(delay)
        (self[delay] - self[delay + 1]).size
      end

      # @param delay [Integer] backwards delay of year
      # @return [Integer] number of lost tiers
      def lost(delay)
        (self[delay + 1] - self[delay]).size
      end

      # @param delay [Integer] backwards delay of year
      # @return [Integer] number of kept tiers
      def kept(delay)
        (self[delay] & self[delay + 1]).size
      end

      # @return [Array] line for board report
      def bilan
        (BACK - 1).downto(0).each.reduce([total(BACK)]) do |list, dly|
          list + [lost(dly), kept(dly), acquired(dly), total(dly)]
        end
      end
    end

    # build the pdf executive report
    # @param [Path] dir directory to write the file in
    # @return [Path] file written
    # @param [Hash] mode connection mode
    def self.dashboard_file(mode, dir)
      J2R.jaccess(mode)
      filename = "Tableau_de_bord_#{J2R::Audits.day}.pdf"
      path = File.join(dir, filename)
      report = Audits::Numbers.dashboard
      report.title = "Tableau de bord [#{J2R::Audits.day}]"
      report.to_pdf_file(path)
    end
  end
end
