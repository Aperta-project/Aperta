require 'rails_helper'

describe TechCheckScenario do
  subject(:context) { TechCheckScenario.new(task) }
  let(:paper) { FactoryGirl.create(:paper, journal: FactoryGirl.create(:journal)) }
  let(:task) { FactoryGirl.create(:initial_tech_check_task, paper: paper) }

  describe "rendering a template" do
    it "renders the intro" do
      card_content = FactoryGirl.create(:card_content, ident: 'tech-check-email--email-intro')
      task.answers.create!(card_content: card_content, value: 'this is the intro', paper: paper)
      template = "{{ intro }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq('this is the intro')
    end

    it "renders the footer" do
      card_content = FactoryGirl.create(:card_content, ident: 'tech-check-email--email-footer')
      task.answers.create!(card_content: card_content, value: 'this is the outro', paper: paper)
      template = "{{ footer }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq('this is the outro')
    end

    it "renders the sendback reasons" do
      parent = FactoryGirl.create(:card_content, content_type: 'sendback-reason', value_type: 'boolean')
      reasons = FactoryGirl.create(:card_content, content_type: 'paragraph-input', parent: parent)
      task.answers.create!(card_content: reasons, value: 'it is ugly', paper: paper)
      task.answers.create!(card_content: reasons, value: 'it is wrong', paper: paper)
      template = "{% for reason in sendback_reasons %}{{ reason.value }}, {% endfor %}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq('it is ugly, it is wrong, ')
    end

    it "implements the paper context" do
      template = "{{ manuscript.title }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(paper.title)
    end
  end
end
