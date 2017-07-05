require 'rails_helper'

describe InvitationContext do
  subject(:context) do
    InvitationContext.new(invitation)
  end

  let(:invitation) do
    FactoryGirl.build(:invitation, :invited)
  end

  context 'rendering an invitation' do
    def check_render(template, expected)
      expect(Liquid::Template.parse(template).render(context))
        .to eq(expected)
    end

    it 'renders the state' do
      check_render("{{ state }}", invitation.state)
    end
  end
end
