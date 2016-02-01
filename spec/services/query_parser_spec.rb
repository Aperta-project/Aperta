require 'rails_helper'

describe QueryParser do
  describe '#parse' do
    it 'parses type queries' do
      parse = QueryParser.parse 'TYPE IS research'
      expect(parse).to eq(ParsedQuery.new(type: 'research'))
    end

    it 'parses decision queries' do
      parse = QueryParser.parse 'DECISION IS major revision'
      expect(parse).to eq(ParsedQuery.new(decision: 'major revision'))
    end

    it 'parses status queries' do
      parse = QueryParser.parse 'STATUS IS submitted'
      expect(parse).to eq(
        ParsedQuery.new(status: 'submitted'))
    end

    it 'parses raw title queries' do
      parse = QueryParser.parse 'composite abuse scale'
      expect(parse).to eq(
        ParsedQuery.new(title: 'composite abuse scale'))
    end

    it 'parses framed title queries' do
      q = 'TITLE IS composite abuse scale (AND other things)'
      parse = QueryParser.parse q
      expect(parse).to eq(
        ParsedQuery.new(title: 'composite abuse scale (AND other things)'))
    end

    it 'parses raw doi queries' do
      parse = QueryParser.parse '1241251'
      expect(parse).to eq(
        ParsedQuery.new(doi: '1241251'))
    end

    it 'parses framed doi queries' do
      parse = QueryParser.parse 'DOI IS 1241251'
      expect(parse).to eq(
        ParsedQuery.new(doi: '1241251'))
    end

    it 'parses OR statements' do
      parse = QueryParser.parse 'STATUS IS rejected OR STATUS IS withdrawn'
      expect(parse).to eq(
        ParsedQuery.new([
          ParsedQuery.new(status: 'withdrawn'),
          ParsedQuery.new(status: 'rejected')
        ]))
    end

    it 'parses AND statements' do
      parse = QueryParser.parse 'STATUS IS rejected AND TYPE IS research'
      expect(parse).to eq(
        ParsedQuery.new(status: 'rejected', type: 'research')
      )
    end

    it 'parses parenthetical statements' do
      q = 'TYPE IS research AND (STATUS IS rejected OR STATUS IS withdrawn)'
      parse = QueryParser.parse q
      expect(parse).to eq(
        ParsedQuery.new([
          ParsedQuery.new(status: 'withdrawn', type: 'research'),
          ParsedQuery.new(status: 'rejected', type: 'research')
        ]))
    end

    it 'parses STATUS IS NOT statements' do
      parse = QueryParser.parse 'STATUS IS NOT unsubmitted'
      expect(parse).to eq(
        ParsedQuery.new(not_status: 'unsubmitted'))
    end
  end
end
