# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe TechCheckScenario do
  subject(:context) { TechCheckScenario.new(task) }
  let(:paper) { FactoryGirl.create(:paper, journal: FactoryGirl.create(:journal)) }
  let (:phase1) { FactoryGirl.create(:phase, position: 1, paper: paper) }
  let (:phase2) { FactoryGirl.create(:phase, position: 2, paper: paper) }
  let(:task) { FactoryGirl.create(:initial_tech_check_task, paper: paper, phase: phase1, position: 1) }
  let(:tech_check_parent) { FactoryGirl.create(:card_content, content_type: 'tech-check', value_type: 'boolean') }

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
        template_body = LetterTemplate.new(body: template).render(context).body
        # TODO: The ordering here should be deterministic
        expect(template_body).to match('it is ugly')
        expect(template_body).to match('it is wrong')
      end
    end

    context 'when rendering sendback reasons' do
      let(:task2) { FactoryGirl.create(:final_tech_check_task, paper: paper, phase: phase1, position: 2) }
      let(:tech_check_parent2) { FactoryGirl.create(:card_content, content_type: 'tech-check', value_type: 'boolean') }
      let(:task3) { FactoryGirl.create(:revision_tech_check_task, paper: paper, phase: phase2, position: 1) }
      let(:tech_check_parent3) { FactoryGirl.create(:card_content, content_type: 'tech-check', value_type: 'boolean') }

      let(:sendback_parent) { FactoryGirl.create(:card_content, content_type: 'sendback-reason', value_type: 'boolean', parent: tech_check_parent) }
      let(:reasons) { FactoryGirl.create(:card_content, content_type: 'paragraph-input', parent: sendback_parent) }

      let(:sendback_parent2) { FactoryGirl.create(:card_content, content_type: 'sendback-reason', value_type: 'boolean', parent: tech_check_parent2) }
      let(:reasons2) { FactoryGirl.create(:card_content, content_type: 'paragraph-input', parent: sendback_parent2) }

      let(:sendback_parent3) { FactoryGirl.create(:card_content, content_type: 'sendback-reason', value_type: 'boolean', parent: tech_check_parent3) }
      let(:reasons3) { FactoryGirl.create(:card_content, content_type: 'paragraph-input', parent: sendback_parent3) }

      it "renders all sendback reasons if all tech checks are unpassed" do
        task.card_version.content_root.children << tech_check_parent
        task.card_version.card_contents << tech_check_parent
        task2.card_version.content_root.children << tech_check_parent2
        task2.card_version.card_contents << tech_check_parent2
        task3.card_version.content_root.children << tech_check_parent3
        task3.card_version.card_contents << tech_check_parent3

        task.answers.create!(card_content: tech_check_parent, value: 'f', paper: paper)
        task2.answers.create!(card_content: tech_check_parent2, value: 'f', paper: paper)
        task3.answers.create!(card_content: tech_check_parent3, value: 'f', paper: paper)

        task.answers.create!(card_content: reasons, value: 'it is ugly', paper: paper)
        task3.answers.create!(card_content: reasons3, value: 'it is devoid of value', paper: paper)
        task2.answers.create!(card_content: reasons2, value: 'I hate it', paper: paper)
        task2.answers.create!(card_content: reasons2, value: 'it is the worst', paper: paper)
        task3.answers.create!(card_content: reasons3, value: 'it is totally useless', paper: paper)
        task.answers.create!(card_content: reasons, value: 'it is wrong', paper: paper)

        template = "{% for reason in paperwide_sendback_reasons %}{{ reason.value }}, {% endfor %}"
        template_body = LetterTemplate.new(body: template).render(context).body
        # TODO: The ordering here should be deterministic
        expect(template_body).to match('it is ugly')
        expect(template_body).to match('it is wrong')
        expect(template_body).to match('I hate it')
        expect(template_body).to match('it is the worst')
        expect(template_body).to match('it is devoid of value')
        expect(template_body).to match('it is totally useless')
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
        template_body = LetterTemplate.new(body: template).render(context).body
        # TODO: The ordering here should be deterministic
        expect(template_body).to match('it is ugly')
        expect(template_body).to match('it is wrong')
      end
    end

    it "implements the paper context" do
      template = "{{ manuscript.title }}"
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(paper.title)
    end
  end
end
