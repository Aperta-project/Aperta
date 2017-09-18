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

    it 'has valid liquid syntax in subject' do
      letter_template =
        FactoryGirl.build(:letter_template,
                           subject: "{{ subject }")
      expect(letter_template).to_not be_valid
      expect(letter_template.errors[:subject])
        .to include("Variable '{{ subject }' was not properly terminated with regexp: /\\}\\}/")
    end

    it 'has valid liquid syntax in body' do
      letter_template =
        FactoryGirl.build(:letter_template,
                           body: "Interesting text about {{ subject }} from {{ email }")
      expect(letter_template).to_not be_valid
      expect(letter_template.errors[:body])
        .to include("Variable '{{ email }' was not properly terminated with regexp: /\\}\\}/")
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

  describe '#blank_render_fields?' do
    subject do
      parsed_template = Liquid::Template.parse(letter_template.subject)
      letter_template.blank_render_fields?(parsed_template, letter_context)
    end
    let(:letter_template) { FactoryGirl.create :letter_template }

    context 'with missing information' do
      let(:letter_context) do
        { 'subject': '' }
      end
      context 'at the top level' do
        before { letter_template.subject = '{{ subject }}' }

        it { should be true }
      end

      context 'within a for loop' do
        before { letter_template.subject = '{% for i in [0,1] %}{{ subject }}{% endfor %}' }

        it { should be true }
      end

      context 'within an unrelated if statement' do
        before { letter_template.subject = '{% if true %}{{ subject }}{% endif %}' }

        it { should be true }
      end
    end

    context 'with information' do
      let(:letter_context) do
        { subject: 'Great paper!' }
      end
      context 'at the top level' do
        before { letter_template.subject = '{{ subject }}' }

        it { should be false }
      end

      context 'within a for loop' do
        before { letter_template.subject = '{% for i in [0,1] %}{{ subject }}{% endfor %}' }

        it { should be false }
      end

      context 'within an unrelated if statement' do
        before { letter_template.subject = '{% if true %}{{ subject }}{% endif %}' }

        it { should be false }
      end
    end
  end
end
