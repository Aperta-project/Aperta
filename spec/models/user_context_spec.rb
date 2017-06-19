require 'rails_helper'

describe UserContext do
  subject(:context) do
    UserContext.new(user)
  end

  let(:user) do
    FactoryGirl.build(:user)
  end

  context 'rendering a user' do
    def check_render(template, expected)
      expect(Liquid::Template.parse(template).render(context))
        .to eq(expected)
    end

    it 'renders a first name' do
      check_render("{{ first_name }}", user.first_name)
    end

    it 'renders a last name' do
      check_render("{{ last_name }}", user.last_name)
    end

    it 'renders an email' do
      check_render("{{ email }}", user.email)
    end
  end
end
