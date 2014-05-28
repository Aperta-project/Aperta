require 'spec_helper'

describe PaperFactory do
  let(:mmt) do
    FactoryGirl.create(:manuscript_manager_template, template: {
      phases: [{
        name: "First Phase",
        task_types: [PaperAdminTask.to_s, Declaration::Task.to_s]
      }]
    })
  end
  let(:journal) { FactoryGirl.create(:journal, manuscript_manager_templates: [mmt]) }
  let(:user) { FactoryGirl.create :user }

  describe "#apply_template" do
    let(:paper) { FactoryGirl.create(:paper, journal: journal, paper_type: mmt.paper_type) }
    let(:paper_factory) { PaperFactory.new(paper, user) }

    it "reifies the phases for the given paper from the correct MMT" do
      expect {
        paper_factory.apply_template
      }.to change { paper.phases.count }.by(mmt.phases.count)

      expect(paper.phases.first.name).to eq(mmt.phases.first["name"])
    end

    it "reifies the tasks for the given paper from the correct MMT" do
      expect {
        paper_factory.apply_template
      }.to change { paper.tasks.count }.by(2)

      expect(paper.tasks.pluck(:type)).to match_array(['PaperAdminTask', 'Declaration::Task'])
    end

    it "sets assignee to tasks with role = author" do
      paper_factory.apply_template
      expect(paper.tasks.where(type: 'PaperAdminTask').first.assignee).to be_nil
      expect(paper.tasks.where(type: 'Declaration::Task').first.assignee).to eq(user)
    end
  end

  describe ".create" do
    let(:paper_attrs) { FactoryGirl.attributes_for(:paper, journal_id: journal.id, paper_type: mmt.paper_type) }
    subject do
      PaperFactory.create(paper_attrs, user)
    end

    it "creates an author" do
      expect { subject }.to change { Author.count }.by 1
    end

    it "sets the user as the first author on the paper's first author group" do
      expect(subject.author_groups.first).to eq Author.last.author_group
      expect(Author.last.first_name).to eq(user.first_name)
    end

    it "sets the user" do
      expect(subject.user).to eq(user)
    end

    it "sets the author" do
      expect(subject.authors.first["first_name"]).to eq(user.first_name)
    end

    it "applies the template" do
      expect(subject.phases.count).to eq(1)
    end

    it "saves the paper" do
      expect(subject).to be_persisted
    end

    it "creates author groups" do
      expect {
        subject
      }.to change { AuthorGroup.count }.by 3
    end

    context "with non-existant template" do
      let(:paper_attrs) { FactoryGirl.attributes_for(:paper, journal_id: journal.id, paper_type: "Opinion Piece") }
      it "adds an error on paper_type" do
        expect(subject.errors[:paper_type].length).to eq(1)
      end
    end
  end
end
