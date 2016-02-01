require 'rails_helper'

describe QueryParser do
  describe '#parse' do
    before do
      QueryParser.clear_joins
    end

    it 'parses type queries' do
      parse = QueryParser.parse 'TYPE IS research'
      expect(parse.to_sql).to eq("\"papers\".\"paper_type\" = 'research'")
    end

    it 'parses decision queries' do
      parse = QueryParser.parse 'DECISION IS major revision'
      expect(parse.to_sql).to eq(
        "\"decisions\".\"verdict\" = 'major revision'")
    end

    it 'parses status queries' do
      parse = QueryParser.parse 'STATUS IS submitted'
      expect(parse.to_sql).to eq(
        "\"papers\".\"publishing_state\" = 'submitted'")
    end

    it 'parses raw title queries' do
      parse = QueryParser.parse 'composite abuse scale'
      expect(parse.to_sql).to eq(
        "to_tsvector('english', \"papers\".\"title\") @@\
 to_tsquery('english', 'composite&abuse&scale')")
    end

    it 'parses framed title queries' do
      q = 'TITLE IS composite abuse scale (AND other things)'
      parse = QueryParser.parse q
      expect(parse.to_sql).to eq(
        "to_tsvector('english', \"papers\".\"title\") @@\
 to_tsquery('english', 'composite&abuse&scale&(AND&other&things)')")
    end

    it 'parses raw doi queries' do
      parse = QueryParser.parse '1241251'
      expect(parse.to_sql).to eq("\"papers\".\"doi\" ILIKE '%1241251%'")
    end

    it 'parses framed doi queries' do
      parse = QueryParser.parse 'DOI IS 1241251'
      expect(parse.to_sql).to eq("\"papers\".\"doi\" ILIKE '%1241251%'")
    end

    it 'parses OR statements' do
      parse = QueryParser.parse 'STATUS IS rejected OR STATUS IS withdrawn'
      expect(parse.to_sql).to eq(
        "(\"papers\".\"publishing_state\" = 'rejected' OR\
 \"papers\".\"publishing_state\" = 'withdrawn')")
    end

    it 'parses AND statements' do
      parse = QueryParser.parse 'STATUS IS rejected AND TYPE IS research'
      expect(parse.to_sql).to eq(
        "\"papers\".\"publishing_state\" = 'rejected' AND\
 \"papers\".\"paper_type\" = 'research'")
    end

    it 'parses parenthetical statements' do
      q = 'TYPE IS research AND (STATUS IS rejected OR STATUS IS withdrawn)'
      parse = QueryParser.parse q
      expect(parse.to_sql).to eq(
        "\"papers\".\"paper_type\" = 'research' AND\
 (\"papers\".\"publishing_state\" = 'rejected' OR\
 \"papers\".\"publishing_state\" = 'withdrawn')")
    end

    it 'parses STATUS IS NOT statements' do
      parse = QueryParser.parse 'STATUS IS NOT unsubmitted'
      expect(parse.to_sql).to eq(
        "\"papers\".\"publishing_state\" != 'unsubmitted'")
    end
  end
end
