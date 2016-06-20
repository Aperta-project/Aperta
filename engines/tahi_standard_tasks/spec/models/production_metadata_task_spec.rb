require 'rails_helper'

describe TahiStandardTasks::ProductionMetadataTask do

  def create_task_with_answer(ident:, answer:, value_type: 'text')
    NestedQuestionableFactory.create(
      FactoryGirl.create(:production_metadata_task),
      questions: [
        {
          ident: ident,
          answer: answer,
          value_type: value_type
        }
      ]
    )
  end

  describe '.restore_defaults' do
    include_examples '<Task class>.restore_defaults update title to the default'
    include_examples '<Task class>.restore_defaults update old_role to the default'
  end

  context "validations" do
    context "task not just marked complete" do
      let(:task) { FactoryGirl.build(:production_metadata_task) }
      before { allow(task).to receive(:newly_complete?).and_return(false) }

      it "is valid" do
        expect(task).to be_valid
      end
    end

    context "task just marked complete" do
      let(:task) { FactoryGirl.build(:production_metadata_task) }

      before { allow(task).to receive(:newly_complete?).and_return(true) }

      it "requires volume_number to be numeric" do
        expect(task).to_not be_valid
        expect(task.error_on(:volume_number)).to include(/must be a whole number/i)
      end

      it "requires issue_number to be numeric" do
        expect(task).to_not be_valid
        expect(task.error_on(:issue_number)).to include(/must be a whole number/i)
      end

      describe "publication_date" do
        context "with missing date" do
          it "has no publication date error" do
            task.valid?
            expect(task.error_on(:publication_date)).to be_empty
          end
        end

        context "with valid date format" do
          before { allow(task).to receive(:publication_date).and_return("01/01/2000") }

          it "has no publication date error" do
            task.valid?
            expect(task.error_on(:publication_date)).to be_empty
          end
        end

        context "with invalid date format" do
          before { allow(task).to receive(:publication_date).and_return("9999") }

          it "has invalid publication_date" do
            expect(task).to_not be_valid
            expect(task.error_on(:publication_date)).to include(/must be a date/)
          end
        end

      end

    end
  end

  describe "#publication_date" do
    context "when answer missing" do
      let(:task) { FactoryGirl.build(:production_metadata_task) }

      it "returns nil" do
        expect(task.publication_date).to eq(nil)
      end
    end

    context "when answer present" do
      let(:task) do
        create_task_with_answer(ident: "production_metadata--publication_date",
                    answer: "12/22/2000")
      end

      it "returns the proxied answer" do
        expect(task.publication_date).to eq("12/22/2000")
      end
    end
  end

  describe "#volume_number" do
    context "when answer missing" do
      let(:task) { FactoryGirl.build(:production_metadata_task) }

      it "returns nil" do
        expect(task.volume_number).to eq(nil)
      end
    end

    context "when answer present" do
      let(:task) do
        create_task_with_answer(ident: "production_metadata--volume_number",
                    answer: "1234")
      end

      it "returns the proxied answer" do
        expect(task.volume_number).to eq("1234")
      end
    end
  end

  describe "#issue_number" do
    context "when answer missing" do
      let(:task) { FactoryGirl.build(:production_metadata_task) }

      it "returns nil" do
        expect(task.issue_number).to eq(nil)
      end
    end

    context "when answer present" do
      let(:task) do
        create_task_with_answer(ident: "production_metadata--issue_number",
                    answer: "1234")
      end

      it "returns the proxied answer" do
        expect(task.issue_number).to eq("1234")
      end
    end
  end
end
