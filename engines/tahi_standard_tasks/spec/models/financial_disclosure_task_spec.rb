require 'rails_helper'

describe TahiStandardTasks::FinancialDisclosureTask do
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
        let(:funders) { [double(TahiStandardTasks::Funder)] }

        it "returns the funder's statement" do
          funder1 = funders.first
          expect(funder1)
            .to receive(:funding_statement) { "Funding statement1" }

          expect(task.funding_statement)
            .to eq("Funding statement1")
        end
      end

      context "multiple funders" do
        let(:funders) do
          [
            double(TahiStandardTasks::Funder),
            double(TahiStandardTasks::Funder)
          ]
        end

        it "returns both of the funder's statement" do
          funder1 = funders.first
          funder2 = funders.second
          expect(funder1)
            .to receive(:funding_statement) { "Funding statement1" }
          expect(funder2)
            .to receive(:funding_statement) { "Funding statement2" }

          expect(task.funding_statement)
            .to eq("Funding statement1\nFunding statement2")
        end
      end
    end
  end
end
