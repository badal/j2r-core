#!/usr/bin/env ruby
# encoding: utf-8

# File: tiers_auditer.rb
# Created: 08/04/12, separated from TiersSearcher: 10/4/14
#
# (c) Michel Demazure <michel@demazure.com>

module JacintheReports
  module Audits
    # methods to build audits for tiers
    class TiersAuditer
      # @param [Integer] tiers_id id of the tiers
      # @param [Integer] year year for reduced posting
      # @return [TiersAuditer] new tiers auditer
      def initialize(tiers_id, year = YEAR)
        @tiers_id = tiers_id
        @the_tiers = J2R::Tiers[tiers_id]
        @year = year
      end

      # @return [Path] path of the temporary audit file
      def audit_path
        output = audit_output
        J2R.to_temp_file('.html', output)
      end

      # @return [StringL] html report extract to be shown
      def extract
        first_block.join("\n")
      end

      # @return [String] html content of the audit file
      def audit_output
        output = [Snippets.head("Audit du tiers #{@tiers_id}"),
                  "<h2>Tiers n° #{@tiers_id}</h2>"]
        output += first_block + client_block
        output += identity if @the_tiers.tiers_type == 1
        output += jacinthe_block
        output << '</html>'
        output.flatten.join("\n")
      end

      # @return [Array<String>] first part of the audit
      def first_block
        [
          "<p><strong>Type : </strong><i>#{@the_tiers.type_tiers_nom}</i></p>",
          '<p>' + @the_tiers.afnor.join('<br>') + '</p>',
          '<p><strong>Particularités : </strong><i>' +
              @the_tiers.particularites + '</i></p>',
          '<p><strong>Rapports : </strong><br><i>' +
              @the_tiers.rapports.join('<br>') + '</i></p>'
        ]
      end

      # @return [Array<String>] client part
      def client_block
        clients = @the_tiers.search(:client_sage)
        if clients.all.size == 1 && clients.first.id == @tiers_id.to_s
          ['<p><strong>Clients :</strong> <i>cas normal</i></p>']
        else
          special_block(clients)
        end
      end

      # @return [Array<String>] client part : case of multiple clients
      # @param [Array<J2R::Client>] clients
      def special_block(clients)
        output = ['<p><strong>Clients : </strong><i>cas spécial</i>']
        output += clients.map do |client|
          "<br><i>Client \"#{client.id}\"</i> : #{client.client_sage_intitule}"
        end
        output << '</p>'
      end

      # @return [Array<String>] identity part of the report
      def identity
        src = Template.from_json_file('tiers')
        table = src.table_for(@tiers_id)
        ['<h3>Identité</h3>', table.doc_for_html]
      end

      # @return [Array<String>] jacinthe content of the report
      def jacinthe_block
        output = item('abonnement', 'Abonnements')
        output += item('livraison', 'Livraisons')
        output += item('adhesion', 'Adhésions')
        output += item('tierce', 'Adhésions tierces')
        output += item('don', 'Dons')
        output + item('achat', 'Achats divers')
      end

      # @return [Array<String>]
      # @param [String] file source file
      # @param [Object] title html subtitle
      def item(file, title)
        src = Template.from_json_file(file)
        table = src.table_for(@tiers_id)
        ["<h3>#{title}</h3>"] + html_block(table)
      end

      # WARNING this uses Table#match because the year field names are different
      # @param [Table] table table to use
      # @return [Array<String>] html formatted extensible table
      def html_block(table)
        return %w(<i>Néant</i>) if table.size == 0
        html_max = table.doc_for_html
        html_min = table.match('Année', @year.to_s).doc_for_html
        Snippets.extensible_element(html_min, html_max)
      end
    end
  end
end
