require 'rails_helper'

describe SimpleReport do
  describe "#new_exiting_count" do
    let(:simple_report) do
      FactoryGirl.build_stubbed(:simple_report,
                                new_accepted: 3,
                                new_rejected: 5,
                                new_withdrawn: 7)
    end
    it "sums new accepted, rejected, and withdrawn" do
      expect(simple_report.new_exiting_count).to eq(15)
    end
  end

  describe "#last_report" do
    context "when there is a previous report" do
      let!(:older_report) { FactoryGirl.create(:simple_report) }
      let!(:newer_report) { FactoryGirl.build_stubbed(:simple_report) }

      it "returns the previous report" do
        expect(newer_report.last_report).to eq(older_report)
      end
    end

    context "when there is not a previous report" do
      let(:only_report) { FactoryGirl.build_stubbed(:simple_report) }
      it "returns nil" do
        expect(only_report.last_report).to be_nil
      end
    end
  end

  describe "#currently_sitting_sum" do
    let!(:example_report) do
      FactoryGirl.build_stubbed(
        :simple_report,
        initially_submitted: 1,
        invited_for_full_submission: 20,
        fully_submitted: 300,
        checking: 4000,
        in_revision: 50_000,
        unsubmitted: 2,
        accepted: 3,
        withdrawn: 4,
        rejected: 5
      )
    end

    it "sums the appropriate field" do
      expect(example_report.currently_sitting_sum).to eq(54_321)
    end
  end

  describe "#previous_report_date" do
    context "when there is no previous report" do
      let(:only_report) { FactoryGirl.build_stubbed(:simple_report) }

      it "returns unix epoch" do
        expect(only_report.previous_report_date)
          .to eq(DateTime.new(1970, 1, 1, 1).utc)
      end
    end

    context "when there is a previous report" do
      let!(:older_report) do
        Timecop.freeze(DateTime.new(2016, 3, 28, 1, 0, 0).utc) do
          FactoryGirl.create(:simple_report)
        end
      end
      let!(:newer_report) { FactoryGirl.build_stubbed(:simple_report) }
      it "returns the last report's created date" do
        expect(newer_report.previous_report_date)
          .to eq(older_report.created_at)
      end
    end
  end
  describe "#previous_in_process_balance" do
    context "when there is no previous report" do
      let(:only_report) { FactoryGirl.build_stubbed(:simple_report) }

      it "returns 0" do
        expect(only_report.previous_in_process_balance).to eq(0)
      end
    end

    context "when there is a previous report" do
      let!(:older_report) do
        FactoryGirl.create(
          :simple_report,
          initially_submitted: 1,
          invited_for_full_submission: 20,
          fully_submitted: 300,
          checking: 4000,
          in_revision: 50_000,
          unsubmitted: 2,
          accepted: 3,
          withdrawn: 4,
          rejected: 5
        )
      end

      let!(:newer_report) { FactoryGirl.build_stubbed(:simple_report) }
      it "returns the last report's in_process_balance" do
        expect(newer_report.previous_in_process_balance)
          .to eq(54_321)
      end
    end
  end

  describe "$build_new_report" do
    it "returns a new SimpleReport" do
      expect(SimpleReport.build_new_report)
        .to be_an_instance_of(SimpleReport)
    end

    describe "#status_queries" do
      let!(:older_repot) do
        Timecop.freeze(DateTime.new(2016, 3, 28, 1, 0, 0).utc) do
          FactoryGirl.create(:simple_report)
        end
      end

      it "builds specific queries" do
        simple_report = SimpleReport.new
        queries = simple_report.instance_eval { build_status_queries }
        sql = queries.values.map(&:to_sql).sort
        expected_sql = [
          "SELECT \"papers\".* FROM \"papers\" WHERE (first_submitted_at >= '2016-03-28 01:00:00.000000')",
          "SELECT DISTINCT \"papers\".* FROM \"papers\" WHERE \"papers\".\"publishing_state\" = 'accepted'",
          "SELECT DISTINCT \"papers\".* FROM \"papers\" WHERE \"papers\".\"publishing_state\" = 'accepted' AND (state_updated_at >= '2016-03-28 01:00:00.000000') AND (\"papers\".\"submitted_at\" IS NOT NULL)",
          "SELECT DISTINCT \"papers\".* FROM \"papers\" WHERE \"papers\".\"publishing_state\" = 'checking'",
          "SELECT DISTINCT \"papers\".* FROM \"papers\" WHERE \"papers\".\"publishing_state\" = 'in_revision'",
          "SELECT DISTINCT \"papers\".* FROM \"papers\" WHERE \"papers\".\"publishing_state\" = 'initially_submitted'",
          "SELECT DISTINCT \"papers\".* FROM \"papers\" WHERE \"papers\".\"publishing_state\" = 'invited_for_full_submission'",
          "SELECT DISTINCT \"papers\".* FROM \"papers\" WHERE \"papers\".\"publishing_state\" = 'rejected'",
          "SELECT DISTINCT \"papers\".* FROM \"papers\" WHERE \"papers\".\"publishing_state\" = 'rejected' AND (state_updated_at >= '2016-03-28 01:00:00.000000') AND (\"papers\".\"submitted_at\" IS NOT NULL)",
          "SELECT DISTINCT \"papers\".* FROM \"papers\" WHERE \"papers\".\"publishing_state\" = 'submitted'",
          "SELECT DISTINCT \"papers\".* FROM \"papers\" WHERE \"papers\".\"publishing_state\" = 'unsubmitted'",
          "SELECT DISTINCT \"papers\".* FROM \"papers\" WHERE \"papers\".\"publishing_state\" = 'withdrawn'",
          "SELECT DISTINCT \"papers\".* FROM \"papers\" WHERE \"papers\".\"publishing_state\" = 'withdrawn' AND (state_updated_at >= '2016-03-28 01:00:00.000000') AND (\"papers\".\"submitted_at\" IS NOT NULL)"
        ]

        expect(sql).to match_array(expected_sql)
      end
    end
  end
end
