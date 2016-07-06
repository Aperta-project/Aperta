require "rails_helper"

describe Snapshot::AuthorTaskSerializer do
  before do
    Rake::Task['nested-questions:seed:authors-task'].reenable
    Rake::Task['nested-questions:seed:authors-task'].invoke
  end

  subject(:serializer) { described_class.new(task) }
  let(:task) { FactoryGirl.create(:authors_task) }

  describe "#as_json" do
    it "serializes to JSON" do
      expect(serializer.as_json).to eq(
        name: "authors-task",
        type: "properties",
        children:  [
          {
            name: "authors--persons_agreed_to_be_named",
            type: "question",
            value: {
              id: NestedQuestion.where(ident: "authors--persons_agreed_to_be_named").first.id,
              title: "Any persons named in the Acknowledgements section of the manuscript, or referred to as the source of a personal communication, have agreed to being so named.",
              answer_type: "boolean",
              answer: nil,
              attachments: []
            },
            children: []
          },
          {
            name: "authors--authors_confirm_icmje_criteria",
            type: "question",
            value: {
              id: NestedQuestion.where(ident: "authors--authors_confirm_icmje_criteria").first.id,
              title: 'All authors have read, and confirm, that they meet, <a href="http://www.icmje.org/recommendations/browse/roles-and-responsibilities/defining-the-role-of-authors-and-contributors.html" target="_blank">ICMJE</a> criteria for authorship.',
              answer_type: "boolean",
              answer: nil,
              attachments: []
            },
            children: []
          },
          {
            name: "authors--authors_agree_to_submission",
            type: "question",
            value: {
              id: NestedQuestion.where(ident: "authors--authors_agree_to_submission").first.id,
              title: "All contributing authors are aware of and agree to the submission of this manuscript.",
              answer_type: "boolean",
              answer: nil,
              attachments: []
            },
            children: []
          },
          { name: "id", type: "integer", value: task.id }
        ]
      )
    end

    context "and the task has authors" do
      let!(:author_bob) { FactoryGirl.create(:author, paper: task.paper) }
      let!(:author_sally) { FactoryGirl.create(:group_author, paper: task.paper) }

      let(:bobs_author_serializer) do
        double(
          "Snapshot::AuthorSerializer",
          as_json: { author: "bob's json here", position: 2 }
        )
      end

      let(:sallys_author_serializer) do
        double(
          "Snapshot::AuthorSerializer",
          as_json: { author: "sally's json here", position: 1 }
        )
      end

      before do
        allow(Snapshot::AuthorSerializer).to receive(:new).with(author_bob).and_return bobs_author_serializer
        allow(Snapshot::GroupAuthorSerializer).to receive(:new).with(author_sally).and_return sallys_author_serializer
      end

      it "serializes each author(s) associated with the task in order by their respective position" do
        expect(serializer.as_json[:children]).to eq([
          {
            name: "authors--persons_agreed_to_be_named",
            type: "question",
            value:
              {
                id: NestedQuestion.where(ident: "authors--persons_agreed_to_be_named").first.id,
                title:
                  "Any persons named in the Acknowledgements section of the manuscript, or referred to as the source of a personal communication, have agreed to being so named.",
                answer_type: "boolean",
                answer: nil,
                attachments: []
              },
            children: []
          },
          {
            name: "authors--authors_confirm_icmje_criteria",
            type: "question",
            value:
              {
                id: NestedQuestion.where(ident: "authors--authors_confirm_icmje_criteria").first.id,
                title: 'All authors have read, and confirm, that they meet, <a href="http://www.icmje.org/recommendations/browse/roles-and-responsibilities/defining-the-role-of-authors-and-contributors.html" target="_blank">ICMJE</a> criteria for authorship.',
                answer_type: "boolean",
                answer: nil,
                attachments: []
              },
            children: []
          },
          {
            name: "authors--authors_agree_to_submission",
            type: "question",
            value:
              {
                id: NestedQuestion.where(ident: "authors--authors_agree_to_submission").first.id,
                title:
                  "All contributing authors are aware of and agree to the submission of this manuscript.",
                answer_type: "boolean",
                answer: nil,
                attachments: []
              },
            children: []
          },
          { name: "id", type: "integer", value: task.id },
          {
            author: "sally's json here",
            position: 1
          },
          {
            author: "bob's json here",
            position: 2
          }
        ])
      end
    end
  end
end
