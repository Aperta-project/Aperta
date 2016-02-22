require 'rails_helper'

feature 'Paper Tracker', js: true do
  let!(:user) { FactoryGirl.create :user, :site_admin }
  let(:per_page) { Kaminari.config.default_per_page }
  let(:search_controls) { '#search-controls-top' }

  scenario 'when only one page worth of results' do
    count = per_page - 1
    count.times { make_matchable_paper }
    login_as(user, scope: :user)
    visit '/paper_tracker'
    expect(find(search_controls)).to have_content('Page 1 of 1')
    within(search_controls) do
      expect(page).to_not have_css('.btn.prev')
      expect(page).to_not have_css('.btn.next')
    end
  end

  scenario 'when 2 pages worth of results' do
    count = per_page + 1
    count.times { make_matchable_paper }
    login_as(user, scope: :user)
    visit '/paper_tracker'
    expect(find(search_controls)).to have_content('Page 1 of 2')
    within(search_controls) do
      expect(page).to_not have_css('.btn.prev')
      expect(page).to have_css('.btn.next')
    end
  end

  scenario 'when on page 2 of 3 pages worth of results' do
    count = 3 * per_page
    count.times { make_matchable_paper }
    login_as(user, scope: :user)
    visit '/paper_tracker?page=2'
    expect(find(search_controls)).to have_content('Page 2 of 3')
    within(search_controls) do
      expect(page).to have_css('.btn.prev')
      expect(page).to have_css('.btn.next')
    end

    within(search_controls) do
      find('.btn.prev').click
      expect(find('.simple-pagination')).to have_content('Page 1 of 3')
      find('.btn.next').click
      expect(find('.simple-pagination')).to have_content('Page 2 of 3')
      find('.btn.next').click
      expect(find('.simple-pagination')).to have_content('Page 3 of 3')
    end
  end

  scenario 'user can search by fuzzy paper title' do
    make_matchable_paper(title: 'paper about dogs')
    login_as(user, scope: :user)
    visit '/paper_tracker'

    fill_in('query-input', with: :papers) # fuzzy
    find('button#search').click
    expect(find('.paper-tracker-table')).to have_content('paper about dogs')
  end

  scenario 'user searches that shouldnt match, dont have results' do
    make_matchable_paper(title: 'paper about dogs')
    login_as(user, scope: :user)
    visit '/paper_tracker'
    fill_in('query-input', with: 'unfindable wordage')
    find('button#search').click
    expect(find('.paper-tracker-table')).not_to have_content('paper about dogs')
  end

  scenario 'user can search by doi' do
    make_matchable_paper(doi: 'journal/foo.12345')
    login_as(user, scope: :user)
    visit '/paper_tracker'
    fill_in('query-input', with: '12345')
    find('button#search').click
    expect(find('.paper-tracker-table')).to have_content('foo.12345')
  end

  scenario 'user can trigger search via enter button' do
    make_matchable_paper(title: 'paper about dogs')
    login_as(user, scope: :user)
    visit '/paper_tracker'
    fill_in('query-input', with: :dog) # fuzzy
    find('#query-input').native.send_keys(:return)
    expect(find('.paper-tracker-table')).to have_content('paper about dogs')
  end

  scenario 'user can sort results by field asc/desc' do
    rows = '.paper-tracker-table tbody tr'
    make_matchable_paper(title: 'AAA')
    make_matchable_paper(title: 'BBB')
    login_as(user, scope: :user)
    visit '/paper_tracker'

    # initial view defaults to created at
    find('tr', text: 'AAA') # built-in waiting - #all doesn't wait
    expect(all(rows)[0].text).to have_content('AAA')
    expect(all(rows)[1].text).to have_content('BBB')

    # first click is asc
    find('a', text: 'Title').click
    find('tr', text: 'AAA') # built-in waiting - #all doesn't wait
    expect(all(rows)[0].text).to have_content('AAA')
    expect(all(rows)[1].text).to have_content('BBB')

    # second click is desc
    find('a', text: 'Title').click
    find('tr', text: 'AAA') # built-in waiting - #all doesn't wait
    expect(all(rows)[0].text).to have_content('BBB')
    expect(all(rows)[1].text).to have_content('AAA')

    # next dev might want to check the arrows here if ya care enough
  end

  def make_matchable_paper(attrs = {})
    paper = FactoryGirl.create(:paper, :with_integration_journal, :submitted, attrs)
    assign_journal_role(paper.journal, user, :admin)
    paper
  end
end
