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

require 'support/pages/journal_page'
require 'support/pages/page'

class AdminDashboardPage < Page
  text_assertions :journal_name, '.journal-thumbnail-name'

  def self.path
    "/admin/journals/all"
  end

  def self.visit
    page.visit path
    new
  end

  def self.admin_section
    "Journals"
  end

  def initialize(*args)
    super
    session.has_content? self.class.admin_section
  end

  def has_journal_name?(name)
    page.has_css?('.admin-drawer-item-title', text: name)
  end

  def has_journal_names?(*names)
    names.all? { |name_text| has_journal_name? name_text }
  end

  def has_journal_paper_count?(count)
    count_text = count == 1 ? "#{count} article" : "#{count} articles"
    find('.journal-thumbnail-paper-count', text: count_text)
  end

  def has_journal_paper_counts?(*counts)
    counts.all? { |count| has_journal_paper_count?(count) }
  end

  def edit_journal(journal_name)
    within('.left-drawer') { click_on journal_name }
    find('.admin-nav-settings').click
    EditJournalFragment.new(find('.journal-thumbnail-edit-form'))
  end

  def visit_journal(journal)
    click_link(journal.name)
    JournalPage.new
  end

  def search(query)
    find(".admin-nav-users").click
    find(".admin-user-search input").set(query)
    find(".admin-user-search button").click
  end

  def search_results(query = nil)
    search(query) if query
    session.has_content? 'Username'
    all('.admin-users-list-list .user-row').map do |el|
      Hash[[:last_name, :first_name, :username].zip(UserRowInSearch.new(el).row_content.map(&:text))]
    end
  end

  def first_search_result(query = nil)
    search(query) if query
    session.has_content? 'Username'
    UserRowInSearch.new(all('.admin-users-list-list .user-row').first, context: page)
  end
end

class UserRowInSearch < PageFragment
  def row_content
    find_all('td')
  end

  def edit_user_details
    find('.username').click
    session.has_content? 'User Details'
    EditModal.new(context.find('.user-detail-overlay'), context: context)
  end

  def add_role(role)
    find('.assign-role-button').click
    session.find('.select2-input').set(role)
    session.find('.select2-result', text: role).click
  end

  def remove_role(role)
    find('.select2-search-choice', text: role).hover
    find('.select2-search-choice', text: role).find('.select2-search-choice-close').click
  end
end

class EditModal < PageFragment
  def first_name=(attr)
    find('.modal-first-name').set(attr)
  end

  def last_name=(attr)
    find('.modal-last-name').set(attr)
  end

  def username=(attr)
    find('.modal-username').set(attr)
  end

  def save
    click_on "Save"
    AdminDashboardPage.new(context: context).tap do |page|
      expect(page).not_to have_css('.overlay-container')
    end
  end

  def cancel
    find('.cancel-link').click
    AdminDashboardPage.new(context: context).tap do |page|
      expect(page).not_to have_css('.overlay-container')
    end
  end
end

class EditJournalFragment < PageFragment
  def name=(name)
    @name = name
    find('.journal-name-edit').set name
  end

  def description=(description)
    find('.journal-description-edit').set description
  end

  def journal_prefix=(journal_prefix)
    find('.journal-doi-journal-prefix-edit').set journal_prefix
  end

  def publisher_prefix=(publisher_prefix)
    find('.journal-doi-publisher-prefix-edit').set publisher_prefix
  end

  def last_doi_issued=(last_doi_issued)
    find('.journal-last-doi-edit').set last_doi_issued
  end

  def attach_cover_image(filename, journal_id)
    all('.journal-logo-upload').first.hover
    attach_file("journal-logo-#{journal_id}", Rails.root.join('spec', 'fixtures', filename), visible: false)
  end

  def save
    click_on "Save"
    # Creating a journal takes time to initialize everything it needs, e.g.
    # its roles and permissions, MMTs, task templates, etc. So be kind to
    # journal and allot it some more time to get set up.
    Capybara.using_wait_time(60) { session.has_content? @name }
  end

  def cancel
    click_on "cancel"
  end
end
