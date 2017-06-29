require 'rails_helper'

describe LetterTemplate do
  describe 'validations' do
    [:letter, :subject].each do |attr_key|
      it "should require a #{attr_key.to_s}" do
        letter_template = FactoryGirl.build(:letter_template, attr_key => '')
        expect(letter_template).not_to be_valid
      end
    end
  end

  describe "#render" do
    let(:letter_template) do
      FactoryGirl.create(:letter_template,
                         subject: "{{ subject }}",
                         to: "{{ email }}",
                         letter: "Interesting text about {{ subject }} from {{ email }}")
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

    it "sets the letter" do
      expected_text = "Interesting text about #{letter_context[:subject]} from #{letter_context[:email]}"
      expect(letter_template.render(letter_context.stringify_keys).letter).to eq(expected_text)
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
