# rubocop:disable Metrics/LineLength, Style/StringLiterals
# I'm disabling line-length in this file because it consists almost
# entirely of long strings where extra whitespace is deadly.

require 'rails_helper'

describe QueryParser do
  describe '#parse' do
    describe 'paper metadata queries' do
      it 'parses type queries' do
        parse = QueryParser.new.parse 'TYPE IS research'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."paper_type" ILIKE 'research'
        SQL
      end

      it 'parses type NOT queries' do
        parse = QueryParser.new.parse 'TYPE IS NOT research'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."paper_type" NOT ILIKE 'research'
        SQL
      end

      it 'parses decision queries' do
        parse = QueryParser.new.parse 'DECISION IS major revision'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "decisions"."verdict" = 'major_revision'
        SQL
      end

      it 'parses status queries' do
        parse = QueryParser.new.parse 'STATUS IS submitted'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."publishing_state" = 'submitted'
        SQL
      end

      it 'parses raw title queries' do
        parse = QueryParser.new.parse 'composite abuse scale'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          to_tsvector('english', "papers"."title") @@ to_tsquery('english', 'composite&abuse&scale')
        SQL
      end

      it 'parses framed title queries' do
        q = 'TITLE IS composite abuse scale (AND other things)'
        parse = QueryParser.new.parse q
        expect(parse.to_sql).to eq(<<-SQL.strip)
          to_tsvector('english', "papers"."title") @@ to_tsquery('english', 'composite&abuse&scale&(AND&other&things)')
        SQL
      end

      it 'parses raw doi queries' do
        parse = QueryParser.new.parse '1241251'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."doi" ILIKE '%1241251%'
        SQL
      end

      it 'parses framed doi queries' do
        parse = QueryParser.new.parse 'DOI IS 1241251'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."doi" ILIKE '%1241251%'
        SQL
      end

      it 'parses OR statements' do
        parse = QueryParser.new.parse 'STATUS IS rejected OR STATUS IS withdrawn'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          ("papers"."publishing_state" = 'rejected' OR "papers"."publishing_state" = 'withdrawn')
        SQL
      end

      it 'parses AND statements' do
        parse = QueryParser.new.parse 'STATUS IS rejected AND TYPE IS research'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."publishing_state" = 'rejected' AND "papers"."paper_type" ILIKE 'research'
        SQL
      end

      it 'parses parenthetical statements' do
        q = 'TYPE IS research AND (STATUS IS rejected OR STATUS IS withdrawn)'
        parse = QueryParser.new.parse q
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."paper_type" ILIKE 'research' AND ("papers"."publishing_state" = 'rejected' OR "papers"."publishing_state" = 'withdrawn')
        SQL
      end

      it 'parses STATUS IS NOT statements' do
        parse = QueryParser.new.parse 'STATUS IS NOT unsubmitted'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."publishing_state" != 'unsubmitted'
        SQL
      end
    end

    describe 'task queries' do
      it 'parses TASK x IS COMPLETE' do
        parse = QueryParser.new.parse 'TASK anytask IS COMPLETE'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks"."title" ILIKE 'anytask' AND "tasks"."completed" = 't'
        SQL
      end

      it 'parses TASK x IS INCOMPLETE' do
        parse = QueryParser.new.parse 'TASK anytask IS INCOMPLETE'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks"."title" ILIKE 'anytask' AND "tasks"."completed" = 'f'
        SQL
      end

      it 'parses HAS TASK x' do
        parse = QueryParser.new.parse 'HAS TASK anytask'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks"."title" ILIKE 'anytask'
        SQL
      end

      it 'parses HAS NO TASK x' do
        parse = QueryParser.new.parse 'HAS NO TASK anytask'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks"."title" NOT ILIKE 'anytask'
        SQL
      end
    end
  end
end
