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
          "decisions_0"."verdict" = 'major_revision'
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
          "tasks_0"."title" ILIKE 'anytask' AND "tasks_0"."completed" = 't'
        SQL
      end

      it 'parses TASK x IS INCOMPLETE' do
        parse = QueryParser.new.parse 'TASK anytask IS INCOMPLETE'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks_0"."title" ILIKE 'anytask' AND "tasks_0"."completed" = 'f'
        SQL
      end

      it 'parses TASK x IS NOT COMPLETE' do
        parse = QueryParser.new.parse 'TASK anytask IS NOT COMPLETE'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks_0"."title" ILIKE 'anytask' AND "tasks_0"."completed" = 'f'
        SQL
      end

      it 'parses HAS TASK x' do
        parse = QueryParser.new.parse 'HAS TASK anytask'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks_0"."title" ILIKE 'anytask'
        SQL
      end

      it 'parses HAS NO TASK x' do
        parse = QueryParser.new.parse 'HAS NO TASK anytask'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."id" NOT IN (SELECT paper_id FROM "tasks" WHERE "tasks"."title" ILIKE 'anytask')
        SQL
      end

      it 'parses TASK x HAS BEEN COMPLETE >' do
        parse = QueryParser.new.parse 'TASK anytask HAS BEEN COMPLETE > 1'
        Timecop.freeze do
          start_time = Time.zone.now.utc.days_ago(1).to_formatted_s(:db)
          expect(parse.to_sql).to eq(<<-SQL.strip)
            "tasks_0"."title" ILIKE 'anytask' AND "tasks_0"."completed_at" < '#{start_time}'
          SQL
        end
      end

      it 'parses TASK x HAS BEEN COMPLETED >' do
        parse = QueryParser.new.parse 'TASK anytask HAS BEEN COMPLETED > 1'
        Timecop.freeze do
          start_time = Time.zone.now.utc.days_ago(1).to_formatted_s(:db)
          expect(parse.to_sql).to eq(<<-SQL.strip)
            "tasks_0"."title" ILIKE 'anytask' AND "tasks_0"."completed_at" < '#{start_time}'
          SQL
        end
      end

      it 'parses ANDed TASK queries as multiple joins' do
        query = 'TASK anytask IS COMPLETE AND TASK someothertask IS INCOMPLETE'
        parse = QueryParser.new.parse query
        expect(parse.to_sql).to eq(<<-SQL.strip)
           "tasks_0"."title" ILIKE 'anytask' AND "tasks_0"."completed" = 't' AND "tasks_1"."title" ILIKE 'someothertask' AND "tasks_1"."completed" = 'f'
        SQL
      end
    end

    describe 'people queries' do
      let!(:president_role) { create(:role, name: 'president') }
      let!(:user) { create(:user, username: 'someuser') }

      it 'parses USER x HAS ROLE president' do
        parse = QueryParser.new.parse 'USER someuser HAS ROLE president'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."user_id" = #{user.id} AND "assignments_0"."role_id" IN (#{president_role.id}) AND "assignments_0"."assigned_to_type" = 'Paper'
        SQL
      end

      it 'parses across multiple roles of same name for USER x HAS ROLE president' do
        president_role2 = create(:role, name: 'president')
        parse = QueryParser.new.parse 'USER someuser HAS ROLE president'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."user_id" = #{user.id} AND "assignments_0"."role_id" IN (#{president_role.id}, #{president_role2.id}) AND "assignments_0"."assigned_to_type" = 'Paper'
        SQL
      end

      it 'parses USER x HAS ANY ROLE' do
        parse = QueryParser.new.parse 'USER someuser HAS ANY ROLE'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."user_id" = #{user.id} AND "assignments_0"."assigned_to_type" = 'Paper'
        SQL
      end

      it 'parses ANYONE HAS ROLE x' do
        parse = QueryParser.new.parse 'ANYONE HAS ROLE president'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."role_id" = #{president_role.id} AND "assignments_0"."assigned_to_type" = 'Paper'
        SQL
      end

      it 'parses NO ONE HAS ROLE x' do
        parse = QueryParser.new.parse 'NO ONE HAS ROLE president'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."role_id" NOT IN (#{president_role.id}) AND "assignments_0"."assigned_to_type" = 'Paper'
        SQL
      end
    end
  end
end
