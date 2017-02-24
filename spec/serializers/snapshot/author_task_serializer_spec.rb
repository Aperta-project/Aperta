require "rails_helper"

describe Snapshot::AuthorTaskSerializer do
  before do
    Rake::Task['card_seed:authors_task'].reenable
    Rake::Task['card_seed:authors_task'].invoke
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
              id: CardContent.where(ident: "authors--persons_agreed_to_be_named").first.id,
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
              id: CardContent.where(ident: "authors--authors_confirm_icmje_criteria").first.id,
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
              id: CardContent.where(ident: "authors--authors_agree_to_submission").first.id,
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
      let!(:author_sally) { FactoryGirl.create(:group_author, paper: task.paper) }
      let!(:author_bob) { FactoryGirl.create(:author, paper: task.paper) }
      it "serializes each author(s) associated with the task in order by their respective position" do
        expect(serializer.as_json[:children]).to match([
          {
            name: "authors--persons_agreed_to_be_named",
            type: "question",
            value:
              {
                id: CardContent.where(ident: "authors--persons_agreed_to_be_named").first.id,
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
                id: CardContent.where(ident: "authors--authors_confirm_icmje_criteria").first.id,
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
                id: CardContent.where(ident: "authors--authors_agree_to_submission").first.id,
                title:
                  "All contributing authors are aware of and agree to the submission of this manuscript.",
                answer_type: "boolean",
                answer: nil,
                attachments: []
              },
            children: []
          },
          { name: "id", type: "integer", value: task.id },
          SnapshotService.registry.serializer_for(author_sally).new(author_sally).as_json,
          SnapshotService.registry.serializer_for(author_bob).new(author_bob).as_json
        ])
      end
    end
  end
end
