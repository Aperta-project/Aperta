require 'rails_helper'

feature 'Paper Tracker', js: true do
  let!(:user) { FactoryGirl.create :user, :site_admin }
  let(:per_page) { Kaminari.config.default_per_page }

  scenario 'when only one page worth of results' do
    count = per_page - 1
    count.times { make_matchable_paper }
    login_as(user, scope: :user)
    visit '/paper_tracker'
    expect(find('.pagination')).to have_content('Page 1 of 1')
    within('.pagination') do
      expect(page).to_not have_css('.btn.prev')
      expect(page).to_not have_css('.btn.next')
    end
  end

  scenario 'when 2 pages worth of results' do
    count = per_page + 1
    count.times { make_matchable_paper }
    login_as(user, scope: :user)
    visit '/paper_tracker'
    expect(find('.pagination')).to have_content('Page 1 of 2')
    within('.pagination') do
      expect(page).to_not have_css('.btn.prev')
      expect(page).to have_css('.btn.next')
    end
  end

  scenario 'when on page 2 of 3 pages worth of results' do
    count = 3 * per_page
    count.times { make_matchable_paper }
    login_as(user, scope: :user)
    visit '/paper_tracker?page=2'
    expect(find('.pagination')).to have_content('Page 2 of 3')
    within('.pagination') do
      expect(page).to have_css('.btn.prev')
      expect(page).to have_css('.btn.next')
    end

    find('.btn.prev').click
    expect(find('.pagination')).to have_content('Page 1 of 3')
    find('.btn.next').click
    expect(find('.pagination')).to have_content('Page 2 of 3')
    find('.btn.next').click
    expect(find('.pagination')).to have_content('Page 3 of 3')
  end

  scenario 'user can search by fuzzy paper title' do
  end

  scenario 'user can search by doi' do
  end

  scenario 'user can clear search box' do
  end

  scenario 'user can sort results by field asc/desc' do
  end

  def make_matchable_paper(attrs={})
    paper = FactoryGirl.create(:paper, :submitted, attrs)
    assign_journal_role(paper.journal, user, :admin)
    paper
  end
end
