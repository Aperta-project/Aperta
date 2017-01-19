require 'rails_helper'

describe NestedQuestionAnswer do
  let(:nested_question) { FactoryGirl.build(:nested_question) }
  subject(:nested_question_answer) do
    FactoryGirl.build(
      :nested_question_answer,
      nested_question: nested_question
    )
  end

  describe "#ready?" do
    context "when the question ready_required_check is required" do
      let(:nested_question) do
        FactoryGirl.build(
          :nested_question,
          ready_required_check: 'required')
      end

      it "is not ready if the value is empty" do
        subject.value = nil
        expect(subject).not_to be_ready
      end

      context "and the value_type is boolean" do
        let(:nested_question) do
          FactoryGirl.build(
            :nested_question,
            ready_required_check: 'required',
            value_type: 'boolean'
          )
        end

        it 'is ready if value is "Y"' do
          allow(subject).to receive(:value_raw).and_return 'Y'
          expect(subject).to be_ready
        end

        it 'is ready if value is "N"' do
          allow(subject).to receive(:value_raw).and_return 'N'
          expect(subject).to be_ready
        end

        it 'is not ready if value is ""' do
          allow(subject).to receive(:value_raw).and_return ''
          expect(subject).not_to be_ready
        end

        context "and the value_type is text" do
          let(:nested_question) do
            FactoryGirl.build(
              :nested_question,
              ready_required_check: 'required',
              value_type: 'text'
            )
          end

          it 'is ready if value is a word' do
            allow(subject).to receive(:value_raw).and_return Faker::Lorem.word
            expect(subject).to be_ready
          end

          it 'is not ready if value is ""' do
            allow(subject).to receive(:value_raw).and_return ''
            expect(subject).not_to be_ready
          end
        end
      end
    end
  end

  context "when the question ready_required_check is if_parent_yes" do
    let(:parent) do
      FactoryGirl.create(
        :nested_question,
        value_type: 'boolean'
      )
    end
    let(:nested_question) do
      FactoryGirl.create(
        :nested_question,
        value_type: 'text',
        parent: parent,
        ready_required_check: 'if_parent_yes'
      )
    end

    context "and the parent is Yes" do
      let!(:parent_answer) do
        FactoryGirl.create(
          :nested_question_answer,
          nested_question: parent,
          value: 'Yes'
        )
      end

      it 'should not be ready if the value is nil' do
        subject.value = nil
        expect(subject).not_to be_ready
      end

      it 'should be ready if the value is set' do
        subject.value = Faker::Lorem.word
        expect(subject).to be_ready
      end
    end

    context "when the question ready_check is long_string" do
      let(:nested_question) do
        FactoryGirl.build(
          :nested_question,
          value_type: 'text',
          ready_check: 'long_string')
      end

      it "is not ready if the value is empty" do
        subject.value = ''
        expect(subject.ready?).to be false
      end

      it "is not ready if the string.size == 5" do
        subject.value = 'abcde'
        expect(subject.ready?).to be false
      end
    end

    context "when the question ready_check is yes" do
      let(:nested_question) do
        FactoryGirl.build(
          :nested_question,
          value_type: 'boolean',
          ready_check: 'yes'
        )
      end

      it "is not ready if the value is empty" do
        allow(subject).to receive(:value_raw).and_return(nil)
        expect(subject).not_to be_ready
      end

      it "is not ready if the value is No" do
        allow(subject).to receive(:yes_no_value).and_return('No')
        expect(subject).not_to be_ready
      end

      it "is ready if the value is Yes" do
        allow(subject).to receive(:yes_no_value).and_return('Yes')
        expect(subject).to be_ready
      end
    end

    context "when the question ready_check is no" do
      let(:nested_question) do
        FactoryGirl.build(
          :nested_question,
          value_type: 'boolean',
          ready_check: 'no'
        )
      end

      it "is not ready if the value is empty" do
        allow(subject).to receive(:value_raw).and_return(nil)
        expect(subject).not_to be_ready
      end

      it "is ready if the value is No" do
        allow(subject).to receive(:yes_no_value).and_return('No')
        expect(subject).to be_ready
      end

      it "is ready if the value is Yes" do
        allow(subject).to receive(:yes_no_value).and_return('Yes')
        expect(subject).not_to be_ready
      end
    end
  end

  describe "validations" do
    it "is valid" do
      expect(nested_question_answer.valid?).to be true
    end

    it "requires value_type" do
      nested_question_answer.value_type = nil
      expect(nested_question_answer.valid?).to be false
    end

    context "and the value_type is boolean" do
      before { nested_question_answer.value_type = "boolean" }

      it "is valid when the value not a truthy value" do
        nested_question_answer.value = false
        expect(nested_question_answer.valid?).to be true
      end
    end

    context "and the value_type is attachment" do
      before { nested_question_answer.value_type = "attachment" }

      it "is valid with a value" do
        nested_question_answer.value = "http://someimagepath.png"
        expect(nested_question_answer.valid?).to be true
      end

      it "is valid without a value" do
        nested_question_answer.value = nil
        expect(nested_question_answer.valid?).to be true
      end
    end

    context "when there is a related decision" do
      let(:decision) { build(:decision) }
      subject(:nested_question_answer) do
        build(:nested_question_answer, decision: decision)
      end

      it "is valid when the decision is a draft" do
        expect(decision).to receive(:completed?).and_return(false)
        nested_question_answer.value = Faker::Lorem.sentence
        expect(nested_question_answer).to be_valid
      end

      it "is not valid when the decision is completed" do
        expect(decision).to receive(:completed?).and_return(true)
        nested_question_answer.value = Faker::Lorem.sentence
        expect(nested_question_answer).not_to be_valid
      end
    end
  end

  describe '#attachments' do
    subject(:nested_question_answer) do
      FactoryGirl.create(:nested_question_answer)
    end
    let!(:question_1){ FactoryGirl.create(:question_attachment, id: 9999 ) }
    let!(:question_2){ FactoryGirl.create(:question_attachment, id: 98) }

    before do
      nested_question_answer.attachments = [
        question_1,
        question_2
      ]
    end

    it 'is ordered by id in ascending order' do
      expect(nested_question_answer.attachments).to \
        eq([question_1, question_2].map(&:reload))

      # Test default order is hard so we're going to peek at the SQL
      # just to make sure.
      expect(nested_question_answer.attachments.to_sql).to \
        match(/ORDER BY id ASC/i)
    end
  end

  describe "#destroy" do
    let!(:nested_question_answer) { FactoryGirl.build(:nested_question_answer) }

    it 'soft deletes nested questions answers' do
      nested_question_answer.save
      nested_question_answer.destroy
      nested_question_answer.reload

      expect(nested_question_answer.deleted_at).to_not be_nil
    end
  end

  describe '#task' do
    context 'and the owner is a Task' do
      let(:task) { Task.new }

      it 'returns the owner' do
        nested_question_answer.owner = task
        expect(nested_question_answer.task).to eq(task)
      end
    end

    context 'and the owner is not a Task, but responds to #task' do
      let(:task) { Task.new }
      let(:owner) { FactoryGirl.build(:author) }

      it 'returns the owner#task' do
        nested_question_answer.owner = owner
        expect(nested_question_answer.task).to eq(owner.task)
      end
    end

    context 'and the owner is something else entirely' do
      it 'raises an exception' do
        expect do
          nested_question_answer.task
        end.to raise_error(NotImplementedError)
      end
    end
  end

  describe "#value_type" do
    context "valid values" do
      it "can set to attachment" do
        nested_question_answer.value_type = "attachment"
        expect(nested_question_answer.value_type).to eq "attachment"
      end

      it "can set to text" do
        nested_question_answer.value_type = "text"
        expect(nested_question_answer.value_type).to eq "text"
      end

      it "can set to boolean" do
        nested_question_answer.value_type = "boolean"
        expect(nested_question_answer.value_type).to eq "boolean"
      end

      it "can set to question-set" do
        nested_question_answer.value_type = "question-set"
        expect(nested_question_answer.value_type).to eq "question-set"
      end
    end
  end

  describe "#value" do
    context "and the value_type is attachment" do
      before { nested_question_answer.value_type = "attachment" }

      it "returns the stored value" do
        nested_question_answer.value = "MyFile.png"
        expect(nested_question_answer.value).to eq "MyFile.png"
      end
    end

    context "and the value_type is text" do
      before { nested_question_answer.value_type = "text" }

      it "returns the stored value as a string" do
        nested_question_answer.value = "Hello there."
        expect(nested_question_answer.value).to eq "Hello there."
      end
    end

    context "and the value_type is question-set" do
      before { nested_question_answer.value_type = "question-set" }

      it "returns the stored value as a string" do
        nested_question_answer.value = "Hello there."
        expect(nested_question_answer.value).to eq "Hello there."
      end
    end

    context "and the value_type is boolean" do
      before { nested_question_answer.value_type = "boolean" }

      %w(t T true True TRUE y Y yes YES 1).each do |truthy_value|
        it "returns true when the value is #{truthy_value}" do
          nested_question_answer.value = truthy_value
          expect(nested_question_answer.value).to be true
        end
      end

      it "returns false otherwise" do
        %w(false f 0 other-value goes here).each do |falsy_value|
          nested_question_answer.value = falsy_value
          expect(nested_question_answer.value).to be false
        end
        nested_question_answer.value = "some other value"
        expect(nested_question_answer.value).to be false
      end
    end

    context "and the value_type is not supported" do
      before { nested_question_answer.value_type = "unsupported-value-type" }

      it "returns nil" do
        expect(nested_question_answer.value).to be nil
      end
    end
  end

  describe "#float_value" do
    before { nested_question_answer.value_type = "text" }

    it "returns a value as a numeric float" do
      nested_question_answer.value = "100"
      expect(nested_question_answer.float_value).to eq(100.0)
    end

    it "returns 0.0 when the value does not contain numeric values" do
      nested_question_answer.value = "asdf"
      expect(nested_question_answer.float_value).to eq(0.0)
    end

    it "returns 0.0 when the value is nil" do
      nested_question_answer.value = nil
      expect(nested_question_answer.float_value).to be(0.0)
    end
  end

  describe "setting the value" do
    let(:owner) { fail("Implement :owner in child context.") }

    before { nested_question_answer.owner = owner }

    context "when the owner responds to :can_change? and returns false" do
      let(:owner) { stub_model(Task, can_change?: false) }

      it "cannot be saved" do
        nested_question_answer.value = "new value"
        expect do
          nested_question_answer.save!
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      context "when .disable_owner_verification is set" do
        it "can be saved" do
          NestedQuestionAnswer.disable_owner_verification = true
          nested_question_answer.value = "new value"
          expect do
            nested_question_answer.save!
          end.to_not raise_error
        end
      end
    end

    context "when the owner responds to :can_change? and returns true" do
      let(:owner) { stub_model(Task, can_change?: true) }

      it "can be saved" do
        nested_question_answer.value = "new value"
        expect do
          nested_question_answer.save!
        end.to_not raise_error
      end
    end

    context "when the owner doesn't respond to :can_change?" do
      let(:owner) { stub_model(Author) }

      it "can be saved" do
        nested_question_answer.value = "new value"
        expect do
          nested_question_answer.save!
        end.to_not raise_error
      end
    end

    context "when there is no owner assigned" do
      let(:owner) { nil }

      it "can be saved" do
        nested_question_answer.value = "new value"
        expect do
          nested_question_answer.save!
        end.to_not raise_error
      end
    end
  end

  describe "#yes_no_value" do
    before { nested_question_answer.value_type = "boolean" }

    it "returns 'Yes' when the value is truthy" do
      nested_question_answer.value = true
      expect(nested_question_answer.yes_no_value).to eq("Yes")
    end

    it "returns 'No' when the value is falsy" do
      nested_question_answer.value = false
      expect(nested_question_answer.yes_no_value).to eq("No")
    end

    it "returns nil when the value is nil" do
      nested_question_answer.value = nil
      expect(nested_question_answer.yes_no_value).to be(nil)
    end
  end
end
