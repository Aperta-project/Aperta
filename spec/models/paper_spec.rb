require 'spec_helper'

describe Paper do
  let(:paper) { Paper.new short_title: 'Example', journal: Journal.new }

  describe "initialization" do
    describe "paper_type" do
      context "when no paper_type is specified" do
        it "defaults to research" do
          expect(paper.paper_type).to eq 'research'
        end
      end

      context "when paper_type is the empty string" do
        it "defaults to research" do
          paper = Paper.new short_title: 'Example', paper_type: ''
          expect(paper.paper_type).to eq 'research'
        end
      end

      context "when paper_type is specified" do
        it "uses specified paper_type" do
          paper = Paper.new short_title: 'Example', paper_type: 'foobar'
          expect(paper.paper_type).to eq 'foobar'
        end
      end
    end

    describe "declarations" do
      it "initializes default declarations" do
        default_declarations = [
          Declaration.new(question: 'Question 1'),
          Declaration.new(question: 'Question 2'),
          Declaration.new(question: 'Question 3')
        ]
        allow(Declaration).to receive(:default_declarations).and_return(default_declarations)

        expect(paper.declarations).to match_array default_declarations
      end

      context "when declarations are specified" do
        it "uses provided declarations" do
          declarations = [Declaration.new(question: 'Question')]
          paper = Paper.new short_title: 'Example', declarations: declarations
          expect(paper.declarations).to match_array declarations
        end
      end
    end

    describe "task manager" do
      it "initializes a new task manager" do
        expect(paper.task_manager).to be_a TaskManager
      end

      context "when a task manager is specified" do
        it "uses the provided task manager" do
          task_manager = TaskManager.new
          paper = Paper.new short_title: 'Example', task_manager: task_manager
          expect(paper.task_manager).to eq task_manager
        end
      end
    end
  end

  describe "validations" do
    describe "short_title" do
      it "must be unique" do
        expect(Paper.new(journal: Journal.create!)).to_not be_valid
      end

      it "must be present" do
        Paper.create! short_title: 'Duplicate', journal: Journal.create!
        expect(Paper.new short_title: 'Duplicate', journal: Journal.create!).to_not be_valid
      end

      it "must be less than 50 characters" do
        paper = Paper.new short_title: 'Longer than 50 characters is not an awesome short title coz short titles should be short, stupid!',
          journal: Journal.create!
        expect(paper).to_not be_valid
      end
    end

    describe "journal" do
      it "must be present" do
        paper = Paper.new(short_title: 'YOLO')
        expect(paper).to_not be_valid
      end
    end

    describe "paper_type" do
      it "must be one of Paper::PAPER_TYPES" do
        Paper::PAPER_TYPES.each do |type|
          paper.paper_type = type
          expect(paper).to be_valid
        end
        paper.paper_type = 'invalid paper type'
        expect(paper.error_on(:paper_type).size).to eq(1)
      end
    end
  end

  describe "scopes" do
    let(:ongoing_paper)   { Paper.create! submitted: false, short_title: 'Ongoing', journal: Journal.create! }
    let(:submitted_paper) { Paper.create! submitted: true, short_title: 'Submitted', journal: Journal.create! }

    describe ".submitted" do
      it "returns submitted papers only" do
        expect(Paper.submitted).to_not include(ongoing_paper)
        expect(Paper.submitted).to include(submitted_paper)
      end
    end

    describe ".ongoing" do
      it "returns submitted papers only" do
        expect(Paper.ongoing).to_not include(submitted_paper)
        expect(Paper.ongoing).to include(ongoing_paper)
      end
    end
  end

  describe "associations" do
    describe "declarations" do
      let(:paper) do
        Paper.create! short_title: 'Paper with declarations',
          journal: Journal.create!,
          declarations: [
            Declaration.new(question: "Q1"),
            Declaration.new(question: "Q2")
          ]
      end

      it "returns them in order for consistency" do
        old_declarations = paper.declarations
        paper.declarations.first.answer = 'icecream'
        paper.declarations.first.save!
        expect(paper.reload.declarations).to eq(old_declarations)
      end
    end
  end

  describe "#editor" do
    let(:user) { User.create! username: 'bob', email: 'bobdylan@example.com', password: 'password', password_confirmation: 'password' }
    context "when the paper has an editor" do
      before { PaperRole.create! user: user, paper: paper, editor: true }
      specify { expect(paper.editor).to eq(user) }
    end

    context "when the paper doesn't have an editor" do
      specify { expect(paper.editor).to be_nil }
    end
  end
end
