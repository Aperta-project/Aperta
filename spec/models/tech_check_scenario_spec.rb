require 'rails_helper'

describe TechCheckScenario do
  subject(:context) { TechCheckScenario.new(task) }
  let(:paper) { FactoryGirl.create(:paper, journal: FactoryGirl.create(:journal)) }
  let(:task) { FactoryGirl.create(:initial_tech_check_task, paper: paper) }
  let(:task2) { FactoryGirl.create(:final_tech_check_task, paper: paper) }
  let(:tech_check_parent) { FactoryGirl.create(:card_content, content_type: 'tech-check', value_type: 'boolean') }
  let(:tech_check_parent2) { FactoryGirl.create(:card_content, content_type: 'tech-check', value_type: 'boolean') }

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

    context 'when rendering sendback_reasons' do
      let(:parent) { FactoryGirl.create(:card_content, content_type: 'sendback-reason', value_type: 'boolean') }
      let(:reasons) { FactoryGirl.create(:card_content, content_type: 'paragraph-input', parent: parent) }

      it "renders the sendback reasons for the given task" do
        task.answers.create!(card_content: reasons, value: 'it is ugly', paper: paper)
        task.answers.create!(card_content: reasons, value: 'it is wrong', paper: paper)
        template = "{% for reason in sendback_reasons %}{{ reason.value }}, {% endfor %}"
        expect(LetterTemplate.new(body: template).render(context).body)
          .to eq('it is ugly, it is wrong, ')
      end
    end

    context 'when rendering sendback reasons' do
      let(:sendback_parent) { FactoryGirl.create(:card_content, content_type: 'sendback-reason', value_type: 'boolean', parent: tech_check_parent) }
      let(:reasons) { FactoryGirl.create(:card_content, content_type: 'paragraph-input', parent: sendback_parent) }

      it "renders all sendback reasons if all tech checks are unpassed" do
        task.card_version.content_root.children << tech_check_parent
        task.card_version.card_contents << tech_check_parent

        task2.card_version.content_root.children << tech_check_parent2
        task2.card_version.card_contents << tech_check_parent2

        task.answers.create!(card_content: tech_check_parent, value: 'f', paper: paper)
        task2.answers.create!(card_content: tech_check_parent2, value: 'f', paper: paper)

        task.answers.create!(card_content: reasons, value: 'it is ugly', paper: paper)
        task.answers.create!(card_content: reasons, value: 'it is wrong', paper: paper)
        task2.answers.create!(card_content: reasons, value: 'it is the worst', paper: paper)
        task2.answers.create!(card_content: reasons, value: 'I hate it', paper: paper)

        template = "{% for reason in paperwide_sendback_reasons %}{{ reason.value }}, {% endfor %}"
        template_body = LetterTemplate.new(body: template).render(context).body
        answers = CardContent.find_by(content_type: 'paragraph-input').answers

        answers.length.times { |n| expect(template_body).to match(answers[n].value) }
      end

      it "only renders reasons from unpassed tech checks" do
        task.card_version.content_root.children << tech_check_parent
        task.card_version.card_contents << tech_check_parent

        task2.card_version.content_root.children << tech_check_parent2
        task2.card_version.card_contents << tech_check_parent2

        task.answers.create!(card_content: tech_check_parent, value: 'f', paper: paper)
        task2.answers.create!(card_content: tech_check_parent2, value: 't', paper: paper)

        task.answers.create!(card_content: reasons, value: 'it is ugly', paper: paper)
        task.answers.create!(card_content: reasons, value: 'it is wrong', paper: paper)
        task2.answers.create!(card_content: reasons, value: 'it is the worst', paper: paper)
        task2.answers.create!(card_content: reasons, value: 'I hate it', paper: paper)
        template = "{% for reason in paperwide_sendback_reasons %}{{ reason.value }}, {% endfor %}"
        expect(LetterTemplate.new(body: template).render(context).body)
          .to eq('it is ugly, it is wrong, ')
      end
    end

    it "implements the paper context" do
      template = "{{ manuscript.title }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(paper.title)
    end
  end
end
