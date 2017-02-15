require "rails_helper"

describe "CardConfig::CardCreator" do
  context "list of idents matches existing NestedQuestion idents" do
    let(:nested_questions) { FactoryGirl.create_list(:nested_question, number_of_nested_questions) }
    let(:creator) { CardConfig::CardCreator.new(idents: nested_questions.map(&:ident),
                                                owner_klass: Author) }

    describe "card creation" do
      let(:number_of_nested_questions) { 2 }

      it "creates a parent Card with correct number of CardContent" do
        card = creator.call

        aggregate_failures("migrated NestedQuestions") do
          expect(card).to_not be_nil
          expect(card.content_root.children.count).to eq(nested_questions.size)
        end
      end

      it "sets the card's name to the owner's class name" do
        card = creator.call
        expect(card.name).to eq("Author")
      end
    end

    describe "card content migration" do
      let(:number_of_nested_questions) { 1 }

      it "creates a parent Card with appropriate CardContent" do
        card = creator.call

        aggregate_failures("migrated NestedQuestions") do
          nested_question = nested_questions.first
          card_content = card.content_root.children.first

          expect(card_content.ident).to eq(nested_question.ident)
          expect(card_content.text).to eq(nested_question.text)
          expect(card_content.value_type).to eq(nested_question.value_type)
        end
      end
    end
  end

  context "list of idents does not match existing NestedQuestion idents" do
    let!(:nested_questions) { FactoryGirl.create_list(:nested_question, 2) }

    it "will fail" do
      creator = CardConfig::CardCreator.new(
        idents: ["an-ident-found-in-handlebars-not-present-in-database"],
        owner_klass: Author
      )
      expect { creator.call }.to raise_error(/expected to find/i)
    end
  end

end
