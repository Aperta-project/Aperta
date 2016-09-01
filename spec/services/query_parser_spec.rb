# rubocop:disable Metrics/LineLength, Style/StringLiterals
# I'm disabling line-length in this file because it consists almost
# entirely of long strings where extra whitespace is deadly.

require 'rails_helper'

module QueryParserSpec
  class FictionalReport < TahiStandardTasks::ReviewerReportTask
  end
end

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

      it 'parses decision queries when the decision IS' do
        parse = QueryParser.new.parse 'DECISION IS major revision'
        expect(parse.to_sql).to eq(<<-SQL.strip_heredoc.chomp)
          "papers"."id" IN (SELECT decisions_0.paper_id from (SELECT paper_id, MAX("decisions"."registered_at") AS registered_at FROM "decisions" WHERE "decisions"."registered_at" IS NOT NULL AND "decisions"."rescinded" != 't' GROUP BY paper_id)
              AS decisions_0
          INNER JOIN decisions ON
              decisions.paper_id = decisions_0.paper_id
              AND decisions.registered_at = decisions_0.registered_at
          WHERE
          "decisions"."verdict" = 'major_revision')
        SQL
      end

      it 'parses decision queries when the decision IS NOT' do
        parse = QueryParser.new.parse 'DECISION IS NOT major revision'
        expect(parse.to_sql).to eq(<<-SQL.strip_heredoc.chomp)
          "papers"."id" IN (SELECT decisions_0.paper_id from (SELECT paper_id, MAX("decisions"."registered_at") AS registered_at FROM "decisions" WHERE "decisions"."registered_at" IS NOT NULL AND "decisions"."rescinded" != 't' GROUP BY paper_id)
              AS decisions_0
          INNER JOIN decisions ON
              decisions.paper_id = decisions_0.paper_id
              AND decisions.registered_at = decisions_0.registered_at
          WHERE
          "decisions"."verdict" != 'major_revision')
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

      it 'parses raw title queries with extra spaces' do
        parse = QueryParser.new.parse ' composite abuse     scale '
        expect(parse.to_sql).to eq(<<-SQL.strip)
          to_tsvector('english', "papers"."title") @@ to_tsquery('english', 'composite&abuse&scale')
        SQL
      end

      it 'parses raw title queries with special whitespace characters' do
        parse = QueryParser.new.parse "composite\tabuse\n scale \r\f"
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
        now_time = DateTime.new(2016, 3, 28, 1, 0, 0).utc
        one_day_ago = now_time.days_ago(1).to_formatted_s(:db)
        Timecop.freeze(now_time) do
          parse = QueryParser.new.parse 'TASK anytask HAS BEEN COMPLETE > 1'
          expect(parse.to_sql).to eq(<<-SQL.strip)
            "tasks_0"."title" ILIKE 'anytask' AND "tasks_0"."completed_at" < '#{one_day_ago}'
          SQL
        end
      end

      it 'parses TASK x HAS BEEN COMPLETED >' do
        now_time = DateTime.new(2016, 3, 28, 1, 0, 0).utc
        one_day_ago = now_time.days_ago(1).to_formatted_s(:db)
        Timecop.freeze(now_time) do
          parse = QueryParser.new.parse 'TASK anytask HAS BEEN COMPLETED > 1'
          expect(parse.to_sql).to eq(<<-SQL.strip)
            "tasks_0"."title" ILIKE 'anytask' AND "tasks_0"."completed_at" < '#{one_day_ago}'
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

      it 'parses TASK x HAS OPEN INVITATIONS' do
        parse = QueryParser.new.parse 'TASK anytask HAS OPEN INVITATIONS'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks_0"."title" ILIKE 'anytask' AND "invitations_1"."state" IN ('pending', 'invited')
        SQL
      end

      it 'parses TASK x HAS NO OPEN INVITATIONS' do
        parse = QueryParser.new.parse 'TASK anytask HAS NO OPEN INVITATIONS'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks_0"."title" ILIKE 'anytask' AND "invitations_1"."state" NOT IN ('pending', 'invited')
        SQL
      end
    end

    describe 'review queries' do
      let(:reviewer_report_types) do
        [TahiStandardTasks::ReviewerReportTask,
         TahiStandardTasks::FrontMatterReviewerReportTask,
         QueryParserSpec::FictionalReport
        ]
      end

      let(:reviewer_report_sql) { reviewer_report_types.map{ |r| "'#{r}'" }.join(', ') }

      it 'includes FictionalReport in the query (NOT) ALL REVIEWS COMPLETE query' do
        all_reviews_parse = QueryParser.new.parse 'ALL REVIEWS COMPLETE'
        not_all_reviews_parse = QueryParser.new.parse 'NOT ALL REVIEWS COMPLETE'

        expect(all_reviews_parse.to_sql).to include('QueryParserSpec::FictionalReport')
        expect(not_all_reviews_parse.to_sql).to include('QueryParserSpec::FictionalReport')
      end

      it 'parses ALL REVIEWS COMPLETE' do
        parse = QueryParser.new.parse 'ALL REVIEWS COMPLETE'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."id" NOT IN (SELECT paper_id FROM "tasks" WHERE "tasks"."type" IN (#{reviewer_report_sql}) AND "tasks"."completed" = 'f') AND "tasks_0"."type" IN (#{reviewer_report_sql})
        SQL
      end

      it 'parses NOT ALL REVIEWS COMPLETE' do
        parse = QueryParser.new.parse 'NOT ALL REVIEWS COMPLETE'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks_0"."type" IN (#{reviewer_report_sql}) AND "tasks_0"."completed" = 'f'
        SQL
      end
    end

    describe 'submission time queries' do
      it 'parses VERSION DATE > DAYS AGO' do
        Timecop.freeze do
          start_time = Time.zone.now.utc.days_ago(3).to_formatted_s(:db)

          parse = QueryParser.new.parse 'VERSION DATE > 3 DAYS AGO'
          expect(parse.to_sql).to eq(<<-SQL.strip)
            "papers"."submitted_at" < '#{start_time}'
          SQL
        end
      end

      it 'parses VERSION DATE < DAYS AGO' do
        Timecop.freeze do
          start_time = Time.zone.now.utc.days_ago(3).to_formatted_s(:db)

          parse = QueryParser.new.parse 'VERSION DATE < 3 DAYS AGO'
          expect(parse.to_sql).to eq(<<-SQL.strip)
            "papers"."submitted_at" >= '#{start_time}'
          SQL
        end
      end

      it 'parses SUBMISSION DATE < mm/dd/yy' do
        Timecop.freeze do |now|
          search_date = now.days_ago(3).strftime("%m/%d/%Y")
          search_date_db = now.days_ago(3).beginning_of_day.to_formatted_s(:db)

          parse = QueryParser.new.parse "SUBMISSION DATE > #{search_date}"
          expect(parse.to_sql).to eq(<<-SQL.strip)
            "papers"."first_submitted_at" >= '#{search_date_db}'
          SQL
        end
      end

      it 'parses SUBMISSION DATE > mm/dd/yy' do
        Timecop.freeze do |now|
          search_date = now.days_ago(3).strftime("%m/%d/%Y")
          search_date_db = now.days_ago(3).beginning_of_day.to_formatted_s(:db)

          parse = QueryParser.new.parse "SUBMISSION DATE < #{search_date}"
          expect(parse.to_sql).to eq(<<-SQL.strip)
            "papers"."first_submitted_at" < '#{search_date_db}'
          SQL
        end
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

      it 'parses USER me HAS ROLE president' do
        parse = QueryParser.new(current_user: user).parse 'USER me HAS ROLE president'
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

      it 'parses USER me HAS ANY ROLE' do
        parse = QueryParser.new(current_user: user).parse 'USER me HAS ANY ROLE'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."user_id" = #{user.id} AND "assignments_0"."assigned_to_type" = 'Paper'
        SQL
      end

      it 'parses ANYONE HAS ROLE x' do
        parse = QueryParser.new.parse 'ANYONE HAS ROLE president'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."role_id" IN (#{president_role.id}) AND "assignments_0"."assigned_to_type" = 'Paper'
        SQL
      end

      it 'parses NO ONE HAS ROLE x' do
        parse = QueryParser.new.parse 'NO ONE HAS ROLE president'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."id" NOT IN (SELECT assigned_to_id FROM "assignments" WHERE "assignments"."role_id" IN (#{president_role.id}) AND "assignments"."assigned_to_type" = 'Paper')
        SQL
      end

      it 'parses USER x HAS ROLE x AND NO ONE HAS ROLE president' do
        janitor_role = create(:role, name: 'janitor')
        parse = QueryParser.new.parse 'USER someuser HAS ROLE janitor AND NO ONE HAS ROLE president'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."user_id" = #{user.id} AND "assignments_0"."role_id" IN (#{janitor_role.id}) AND "assignments_0"."assigned_to_type" = 'Paper' AND "papers"."id" NOT IN (SELECT assigned_to_id FROM "assignments" WHERE "assignments"."role_id" IN (#{president_role.id}) AND "assignments"."assigned_to_type" = 'Paper')
        SQL
      end

      it 'parses USER x HAS ROLE x AND NO ONE HAS ROLE president with extra whitespace' do
        janitor_role = create(:role, name: 'janitor')
        parse = QueryParser.new.parse "\tUSER someuser HAS   \n  ROLE   janitor   AND NO \rONE\t HAS ROLE  president  "
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."user_id" = #{user.id} AND "assignments_0"."role_id" IN (#{janitor_role.id}) AND "assignments_0"."assigned_to_type" = 'Paper' AND "papers"."id" NOT IN (SELECT assigned_to_id FROM "assignments" WHERE "assignments"."role_id" IN (#{president_role.id}) AND "assignments"."assigned_to_type" = 'Paper')
        SQL
      end
    end
  end
end
