require 'rails_helper'

describe JournalContext do
  subject(:context) do
    JournalContext.new(journal)
  end

  let(:journal) do
    FactoryGirl.build(:journal, staff_email: 'us@plos.org')
  end

  context 'rendering a journal' do
    def check_render(template, expected)
      expect(Liquid::Template.parse(template).render(context))
        .to eq(expected)
    end

    it 'renders a name' do
      check_render("{{ name }}", journal.name)
    end

    it 'renders a the staff email' do
      check_render("{{ staff_email }}", journal.staff_email)
    end
  end
end
