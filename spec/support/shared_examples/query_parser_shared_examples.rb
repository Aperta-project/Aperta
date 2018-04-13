# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

RSpec.shared_examples_for 'a query parser date query' do |query:, sql:|
  describe 'when download! fails' do
    it "parses '#{query} = mm/dd/yyyy'" do
      start_time = '04/12/2016'.to_date.beginning_of_day.to_formatted_s(:db)
      end_time = '04/12/2016'.to_date.end_of_day.to_formatted_s(:db)
      Timecop.freeze do
        parse = QueryParser.new.parse "#{query} = 04/12/2016"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          #{sql} BETWEEN '#{start_time}' AND '#{end_time}'
        SQL
      end
    end

    it "parses '#{query} < mm/dd/yyyy'" do
      start_time = '04/12/2016'.to_date.beginning_of_day.to_formatted_s(:db)
      Timecop.freeze do
        parse = QueryParser.new.parse "#{query} < 04/12/2016"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          #{sql} <= '#{start_time}'
        SQL
      end
    end

    it "parses '#{query} > mm/dd/yyyy'" do
      end_time = '04/12/2016'.to_date.end_of_day.to_formatted_s(:db)
      Timecop.freeze do
        parse = QueryParser.new.parse "#{query} > 04/12/2016"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          #{sql} >= '#{end_time}'
        SQL
      end
    end

    it "parses '#{query} <= mm/dd/yyyy'" do
      end_time = '04/12/2016'.to_date.end_of_day.to_formatted_s(:db)
      Timecop.freeze do
        parse = QueryParser.new.parse "#{query} <= 04/12/2016"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          #{sql} <= '#{end_time}'
        SQL
      end
    end

    it "parses '#{query} >= mm/dd/yyyy'" do
      start_time = '04/12/2016'.to_date.beginning_of_day.to_formatted_s(:db)
      Timecop.freeze do
        parse = QueryParser.new.parse "#{query} >= 04/12/2016"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          #{sql} >= '#{start_time}'
        SQL
      end
    end

    it "falls back to today's date when given a bad input date" do
      today = Time.now.utc.end_of_day.to_formatted_s(:db)
      Timecop.freeze do
        parse = QueryParser.new.parse "#{query} > bad date"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          #{sql} >= '#{today}'
        SQL
      end
    end

    it "parses '#{query} = n DAYS AGO'" do
      start_time = Time.now.utc.days_ago(3).beginning_of_day.to_formatted_s(:db)
      end_time = Time.now.utc.days_ago(3).end_of_day.to_formatted_s(:db)
      Timecop.freeze do
        parse = QueryParser.new.parse "#{query} = 3 days ago"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          #{sql} BETWEEN '#{start_time}' AND '#{end_time}'
        SQL
      end
    end

    it "parses '#{query} > n DAYS AGO'" do
      start_time = Time.now.utc.days_ago(3).beginning_of_day.to_formatted_s(:db)
      Timecop.freeze do
        parse = QueryParser.new.parse "#{query} > 3 days ago"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          #{sql} <= '#{start_time}'
        SQL
      end
    end

    it "parses '#{query} < n DAYS AGO'" do
      end_time = Time.now.utc.days_ago(3).end_of_day.to_formatted_s(:db)
      Timecop.freeze do
        parse = QueryParser.new.parse "#{query} < 3 days ago"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          #{sql} >= '#{end_time}'
        SQL
      end
    end

    it "parses '#{query} >= n DAYS AGO'" do
      # >= includes the day, just like how '=' works
      three_days_ago_inclusive = Time.now.utc.days_ago(3).end_of_day.to_formatted_s(:db)
      Timecop.freeze do
        parse = QueryParser.new.parse "#{query} >= 3 days ago"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          #{sql} <= '#{three_days_ago_inclusive}'
        SQL
      end
    end

    it "parses '#{query} <= n DAYS AGO'" do
      # >= includes the day, just like how '=' works
      three_days_ago_inclusive = Time.now.utc.days_ago(3).beginning_of_day.to_formatted_s(:db)
      Timecop.freeze do
        parse = QueryParser.new.parse "#{query} <= 3 days ago"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          #{sql} >= '#{three_days_ago_inclusive}'
        SQL
      end
    end
  end
end
