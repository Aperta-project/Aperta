require 'rails_helper'

describe LetterTemplate do
  describe 'validations' do
    [:body, :subject].each do |attr_key|
      it "requires a #{attr_key}" do
        letter_template = LetterTemplate.new(attr_key => '')
        expect(letter_template).to_not be_valid
        expect(letter_template.errors[attr_key]).to include("can't be blank")
      end
    end

    it 'requires #scenario to name a subclass of TemplateScenario' do
      letter_template = LetterTemplate.new(scenario: "TahiStandardTasks::RegisterDecisionScenario")
      letter_template.valid?
      expect(letter_template.errors[:scenario]).to be_empty

      [nil, 'Blah', 'TemplateScenario'].each do |value|
        letter_template = LetterTemplate.new(scenario: value)
        expect(letter_template).to_not be_valid
        expect(letter_template.errors[:scenario]).to include('must name a subclass of TemplateScenario')
      end
    end
  end

  describe "#render" do
    let(:letter_template) do
      FactoryGirl.create(:letter_template,
                         subject: "{{ subject }}",
                         to: "{{ email }}",
                         body: "Interesting text about {{ subject }} from {{ email }}")
    end

    let(:letter_context) do
      {
        subject: "My subject",
        email: "plos@aperta.tech"
      }
    end

    it "sets a subject" do
      expect(letter_template.render(letter_context.stringify_keys).subject).to eq(letter_context[:subject])
    end

    it "sets the to field" do
      expect(letter_template.render(letter_context.stringify_keys).to).to eq(letter_context[:email])
    end

    it "sets the body" do
      expected_body = "Interesting text about #{letter_context[:subject]} from #{letter_context[:email]}"
      expect(letter_template.render(letter_context.stringify_keys).body).to eq(expected_body)
    end

    context "html sanitization" do
      let(:html_letter_context) do
        {
          subject: "<p>Some html</p>",
          email: "<b>myemail@example.com</b>"
        }
      end

      it "sanitizes the subject" do
        expect(letter_template.render(html_letter_context.stringify_keys).subject).to eq("Some html")
      end

      it "sanitizes the to field" do
        expect(letter_template.render(html_letter_context.stringify_keys).to).to eq("myemail@example.com")
      end
    end
  end
end
