require 'rails_helper'

describe "Question" do

  describe "#after_destroy" do
    #This after_destroy will enable people to show a "last saved" timestamp on cards,
    #even when a question is deleted because it touches the last_updated column of a card.
    context "with an existing journal" do
      it "will allow destroying a custom role" do
        question = FactoryGirl.create(:question)
        task = Task.first
        expect { question.destroy }.to change{ task.reload.updated_at }
      end
    end
  end
end
