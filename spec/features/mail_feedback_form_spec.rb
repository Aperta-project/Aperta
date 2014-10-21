require 'spec_helper'

feature "Mail Feedback form", js: true do
  context 'on the slideout sidebar' do

    let(:admin) do
      create :user, :admin, first_name: "Admin"
    end

    let(:author) do
      create :user, :admin, first_name: "Author"
    end

    let(:journal) { FactoryGirl.create(:journal) }

    let!(:paper1) do
      FactoryGirl.create(:paper, :with_tasks,
      short_title: 'foobar',
      title: 'Foo bar',
      submitted: true,
      journal: journal,
      user: author)
    end

    let!(:paper2) do
      FactoryGirl.create(:paper, :with_tasks,
      short_title: 'bazqux',
      title: 'Baz Qux',
      submitted: true,
      journal: journal,
      user: author)
    end

    before '' do
      sign_in_page = SignInPage.visit
      sign_in_page.sign_in admin
    end

    it 'has Feedback link' do
      within ".navigation" do
        expect(page).to have_content 'Give Feedback'
      end
    end

    context "with a modal window" do
      before do
        expect(page).not_to have_css('.overlay')

        find('.navigation-toggle').click()
        find('.navigation-item-feedback').click()

        expect(page).to have_css('.overlay')
      end

      it 'opens modal overlay when clicked' do
        within('.overlay') do
          expect(page).to have_button 'Send Feedback'
        end
      end

      it "closes the modal when the escape key is pressed" do
        expect(find(".overlay form")).to be_truthy

        find('.overlay').native.send_keys(:escape)
        expect(page).not_to have_css('.overlay')
      end

      it "submits the form when the submit button is pressed" do
        expect(find(".overlay form")).to be_truthy

        click_button 'Send Feedback'
        expect(page).to have_css('.overlay .thanks', visible: true)
      end

    end
  end

end
