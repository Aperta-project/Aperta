require 'rails_helper'

describe AuthorContext do
  subject(:context) do
    AuthorContext.new(author)
  end

  let(:author) do
    FactoryGirl.build(:author)
  end

  context 'rendering an author' do
    def check_render(template, expected)
      expect(LetterTemplate.new(body: template).render(context).body)
        .to eq(expected)
    end

    it 'renders a first name' do
      check_render("{{ first_name }}", author.first_name)
    end

    it 'renders an author initial' do
      check_render("{{ author_initial }}", author.author_initial)
    end

    it 'renders an affiliation' do
      check_render("{{ affiliation }}", author.affiliation)
    end
  end
end
