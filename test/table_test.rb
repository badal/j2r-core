#!/usr/bin/env ruby
# encoding: utf-8

# File: table_spec.rb
# Created: 08/02/12
#
# (c) Michel Demazure <micheldemazure.com>

require_relative 'spec_helper.rb'

include Reports

describe 'Table' do

  let(:letters) { ('A'..'H').to_a }
  let(:table) do
    cols = letters + ['p']
    lines = (1..10).to_a.map do |line|
      letters.map { |letter| "#{letter}#{line}" } << line % 3
    end
    # noinspection RubyArgCount
    Table.new(cols, lines)
  end

  it 'columns' do
    table.columns.must_equal(letters + ['p'])
  end

  it 'size' do
    table.size.must_equal(10)
  end

  it 'take' do
    table.take(5).size.must_equal(5)
  end

  it 'filter' do
    table.match('A', 'A3').size.must_equal(1)
    table.match('B', 'VIDE').size.must_equal(0)
    ->() { table.match_value('Z', 'xxx', true) }.must_raise(NoMethodError)
  end

  it 'all values' do
    list = %w(H1 H10 H2 H3 H4 H5 H6 H7 H8 H9)
    table.all_values('H').must_equal(list)
    table.all_values('p').must_equal(%w(0 1 2))
  end

  it 'cross table' do
    cross = table.cross_table('A', 'p')
    cross.columns.must_equal(%w(A 0 1 2))
    cross.match('0', '1').size.must_equal(3)
    cross.match('1', '1').size.must_equal(4)
    cross.match('2', '1').size.must_equal(3)
  end

  describe 'compare and split' do

    let(:tab) do
      cols = %w(ref blow)
      lines = [%w(U A), %w(V A), %w(U B)]
      # noinspection RubyArgCount
      Table.new(cols, lines)
    end

    it 'compare' do
      tab.compare(['ref'], 'blow', 'A', 'B').size.must_equal(0)
      tab.compare(['ref'], 'blow', 'B', 'A').size.must_equal(1)
    end

    it 'split' do
      blow = tab.split('blow')
      blow.must_be_kind_of(Hash)
      blow.keys.must_equal(%w(A B))
      blow['A'].must_be_kind_of(Table)
      blow['A'].size.must_equal(2)
      blow['B'].size.must_equal(1)
    end

  end
end
