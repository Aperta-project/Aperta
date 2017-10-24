require 'rails_helper'

describe PaperContext do
  subject(:context) do
    PaperContext.new(paper)
  end

  let(:journal) { FactoryGirl.create(:journal, :with_creator_role) }
  let(:paper) do
    FactoryGirl.create(
      :paper,
      abstract: 'abstract',
      journal: journal
    )
  end

  let(:academic_editor) { FactoryGirl.create(:user) }
  let(:handling_editor) { FactoryGirl.create(:user) }

  context 'rendering a paper' do
    def check_render(template, expected)
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(expected)
    end

    it 'renders a title' do
      check_render("{{ title }}", paper.title)
    end

    it 'renders an abstract' do
      check_render("{{ abstract }}", paper.abstract)
    end

    it 'renders a paper type' do
      check_render("{{ paper_type }}", paper.paper_type)
    end

    context 'with Preprint Enabled' do
      let!(:preprint_flag) { FactoryGirl.create :feature_flag, name: "PREPRINT", active: true }

      context 'with preprint opt-in' do
        it 'renders opt-in block' do
          check_render("{% if preprint_opted_in %}opt-in{% endif %}", "opt-in")
        end
      end

      context 'with preprint opt-out' do
        it 'renders opt-out block' do
          paper.preprint_opt_out = true
          paper.save
          check_render("{% if preprint_opted_out %}opt-out{% endif %}", "opt-out")
        end
      end
    end

    context 'with a creator' do
      let(:paper) do
        FactoryGirl.create :paper, :with_creator, journal: journal
      end

      it 'renders creator first name' do
        check_render("{{ creator.first_name }}",
                     paper.creator.first_name)
      end

      it 'renders creator last name' do
        check_render("{{ creator.last_name }}",
                     paper.creator.last_name)
      end

      it 'renders creator full name' do
        check_render("{{ creator.full_name }}",
                     paper.creator.full_name)
      end
    end

    context 'with authors' do
      let(:author_1) do
        FactoryGirl.create(:author, email: 'a1@example.com')
      end
      let(:author_2) do
        FactoryGirl.create(:author, email: 'a2@example.com')
      end
      let(:corresponding_author_1) do
        FactoryGirl.create(:author, :corresponding, email: 'c1@example.com')
      end
      let(:corresponding_author_2) do
        FactoryGirl.create(:author, :corresponding, email: 'c2@example.com')
      end

      before do
        CardLoader.load('Author')
        paper.authors = [author_1, author_2]
        expect(paper.authors).to_not be_empty
      end
      it 'renders authors' do
        result = paper.authors.map(&:email).join(',')
        check_render(
          "{%- assign emails = authors | map: 'email' -%}{{emails | join: ','}}",
          result
        )
      end

      it 'renders corresponding authors as all authors by default' do
        result = paper.authors.map(&:email).join(',')
        check_render(
          "{%- assign emails = authors | map: 'email' -%}{{emails | join: ','}}",
          result
        )
      end

      it 'renders corresponding authors' do
        paper.authors << corresponding_author_1
        paper.authors << corresponding_author_2
        result = [corresponding_author_1.email, corresponding_author_2.email].join(',')
        check_render(
          "{%- assign emails = corresponding_authors | map: 'email' -%}{{emails | join: ','}}",
          result
        )
      end
    end

    context 'with an academic editor' do
      before do
        journal.academic_editor_role ||
          journal.create_academic_editor_role!
        paper.add_academic_editor(academic_editor)
      end

      it 'renders academic editors' do
        check_render("{{ academic_editors[0].first_name }}",
                     academic_editor.first_name)
      end
    end

    context 'with a handling editor' do
      before do
        journal.handling_editor_role ||
          journal.create_handling_editor_role!
        assign_handling_editor_role(paper, handling_editor)
      end

      it 'renders handling editors' do
        check_render("{{ handling_editors[0].first_name }}",
                     handling_editor.first_name)
      end

      it 'renders an editor' do
        check_render("{{ editor.first_name }}",
                     handling_editor.first_name)
      end
    end
  end
end
