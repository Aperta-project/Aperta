require 'rails_helper'

describe NestedQuestion do
  describe "validations" do
    subject(:nested_question) { FactoryGirl.build(:nested_question) }

    it "is valid" do
      expect(nested_question.valid?).to be true
    end

    it "requires ident" do
      nested_question.ident = nil
      expect(nested_question.valid?).to be false
    end

    it "doesn't require an owner_id" do
      nested_question.owner_id = nil
      expect(nested_question.valid?).to be true
    end

    it "requires an owner_type" do
      nested_question.owner_type = nil
      expect(nested_question.valid?).to be false
    end

    it "requires value_type" do
      nested_question.value_type = nil
      expect(nested_question.valid?).to be false
    end

    context "value_type" do
      %w(attachment boolean question-set text).each do |value_type|
        it "is valid when it's #{value_type}" do
          nested_question.value_type = value_type
          expect(nested_question.valid?).to be true
        end
      end
    end
  end

  describe "#attachment?" do
    it "returns true when value_type is for an attachment" do
      question = NestedQuestion.new(value_type: "attachment")
      expect(question.attachment?).to be true
    end
  end

  describe "#destroy" do
    subject(:nested_question) { FactoryGirl.build(:nested_question) }
    it 'soft deletes nested questions' do
      nested_question.destroy

      expect(nested_question.deleted_at).to_not be_nil
    end
  end

  describe '#update_all_exactly!' do
    let(:owner) { FactoryGirl.create(:task) }

    let!(:nested_question_a) do
      FactoryGirl.create(:nested_question, owner: owner)
    end

    let!(:nested_question_b) do
      FactoryGirl.create(:nested_question, owner: owner)
    end

    let(:scope) { NestedQuestion.where(owner: owner) }

    it 'soft deletes any idents that are missing' do
      expect(scope.count).to be(2)
      scope.update_all_exactly!([{ ident: nested_question_a.ident }])
      expect(scope.count).to be(1)
    end

    it 'retains soft deleted idents' do
      expect(scope.count).to be(2)
      scope.update_all_exactly!([{ ident: nested_question_a.ident }])
      expect(NestedQuestion.only_deleted.count).to eq(1)
      expect(NestedQuestion.only_deleted.first).to eq(nested_question_b)
    end

    it 'creates new questions for new idents' do
      expect(scope.count).to be(2)
      scope.update_all_exactly!(
        [{
          ident: nested_question_a.ident
        }, {
          ident: nested_question_b.ident
        }, {
          ident: 'a_cool_new_ident',
          value_type: 'text'
        }])
      expect(scope.count).to be(3)
    end

    it 'updates idents where neccessary' do
      expect(scope.count).to be(2)
      scope.update_all_exactly!(
        [{
          ident: nested_question_a.ident,
          text: 'Some new text'
        }, {
          ident: nested_question_b.ident
        }])

      expect(nested_question_a.reload.text).to eq('Some new text')
    end

    it 'creates children, too' do
      expect(scope.count).to be(2)
      scope.update_all_exactly!(
        [{
          ident: nested_question_a.ident,
          text: 'Some new text',
          children:
            [{
              ident: 'new_ident_yay',
              value_type: 'text'
            }]
        }, {
          ident: nested_question_b.ident
        }])
      expect(scope.count).to be(3)
      expect(nested_question_a.reload.children.count).to be(1)
    end
  end
end
