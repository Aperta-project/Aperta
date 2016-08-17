require 'rails_helper'

describe TahiStandardTasks::TitleAndAbstractTask do
  let!(:paper) do
    FactoryGirl.create :paper, :with_tasks
  end
  let!(:task) do
    FactoryGirl.create(:title_and_abstract_task, paper: paper)
  end

  describe "#paper_abstract" do
    context "is a string" do
      before do
        task.paper_abstract = "hiya"
        task.save!
      end
      it "sets abstract on paper" do
        expect(paper.abstract).to eq("hiya")
      end
    end

    context "is an empty string" do
      before do
        task.paper_abstract = " "
        task.save!
      end
      it "sets abstract on paper to nil" do
        expect(paper.abstract).to eq(nil)
      end
    end
  end

  describe "#paper_title" do
    context "is a string" do
      before do
        task.paper_title = "this is the title"
        task.save!
      end
      it "sets title on paper" do
        expect(paper.title).to eq("this is the title")
      end
    end
  end
end
