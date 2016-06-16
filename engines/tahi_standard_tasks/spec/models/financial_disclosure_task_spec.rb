require 'rails_helper'

describe TahiStandardTasks::FinancialDisclosureTask do
  describe '.restore_defaults' do
    include_examples '<Task class>.restore_defaults update title to the default'
    include_examples '<Task class>.restore_defaults update old_role to the default'
  end

  describe '#funders association' do
    let!(:task) do
      FactoryGirl.create(:financial_disclosure_task, funders: [funder])
    end
    let!(:funder) { FactoryGirl.create(:funder) }

    it 'detroys funders when the task is destroyed' do
      expect do
        task.destroy
      end.to change { task.funders.count }.by(-1)

      expect { funder.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#funding_statement" do
    let!(:task) do
      FactoryGirl.create(:financial_disclosure_task, funders: funders)
    end
    let(:funders) { [] }

    context "no funder" do
      it "is the default statement" do
        expect(task.funding_statement)
          .to eq("The author(s) received no specific funding for this work.")
      end
    end

    context "with funder(s)" do
      context "single funder" do
        let(:funders) do
          [FactoryGirl.create(:funder, name: "funder1", grant_number: "001")]
        end

        it "returns the funder's statement" do
          funder1 = funders.first
          expect(funder1.funding_statement) .to include("001")

          expect(task.funding_statement)
            .to eq(funder1.funding_statement)
        end
      end

      context "multiple funders" do
        let(:funders) do
          [
            FactoryGirl.create(:funder, name: "funder1", grant_number: "001"),
            FactoryGirl.create(:funder, name: "funder2", grant_number: "002")
          ]
        end

        it "returns both of the funder's statement" do
          funder1 = funders.first
          funder2 = funders.second
          expect(funder1.funding_statement) .to include("001")
          expect(funder2.funding_statement) .to include("002")

          expected_statement = [
            funder1.funding_statement, funder2.funding_statement
          ].join(";\n")

          expect(task.funding_statement)
            .to eq(expected_statement)
        end
      end
    end
  end
end
