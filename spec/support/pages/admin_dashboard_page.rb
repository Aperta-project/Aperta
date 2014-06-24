class AdminDashboardPage < Page
  def self.path
    "/admin"
  end

  def self.visit
    page.visit path
    new
  end

  def self.page_header
    "Journals"
  end

  def initialize(*args)
    super
    synchronize_content! self.class.page_header
  end

  def journal_names
    all('.journal-name').map &:text
  end

  def journal_descriptions
    all('.journal-thumbnail-show p').map &:text
  end

  def journal_paper_counts
    all('.journal-paper-count').map { |el| el.text.split(' ')[0].to_i }
  end

  def create_journal
    click_on 'Add new journal'
    EditJournalFragment.new(find '.journal-thumbnail-edit-form')
  end

  def edit_journal(journal_name)
    all('.journal').detect { |j| j.text =~ /#{journal_name}/ }.hover
    all('.edit-icon').first.click
    EditJournalFragment.new(find '.journal-thumbnail-edit-form')
  end

  def visit_journal(journal)
    click_link(journal.name)
    JournalPage.new
  end

  def search(query)
    find(".admin-search-input").set(query)
    find(".admin-search-button").click
  end

  def search_results
    synchronize_content! "Username"
    all('.admin-users .user-row').map do |el|
      Hash[[:first_name, :last_name, :username].zip(el.all('td').map &:text)]
    end
  end

  def first_search_result
    synchronize_content! "Username"
    UserRowInSearch.new(all('.admin-users .user-row').first, context: page)
  end
end

class UserRowInSearch < PageFragment
  def row_content
    all('td')
  end

  def edit_user_details
    click
    synchronize_content! "User Details"
    EditModal.new(context.find('.admin-modal'), context: context)
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
    AdminDashboardPage.new(context: context)
  end

  def cancel
    click_on "Cancel"
    AdminDashboardPage.new(context: context)
  end

  def reset_password
    find('.reset-password').click
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

  def attach_cover_image(filename, journal_id)
    all('.journal-logo-upload').first.hover
    attach_file("journal-logo-#{journal_id}", Rails.root.join('spec', 'fixtures', filename), visible: false)
  end

  def save
    click_on "Save"
    synchronize_content! @name
  end

  def cancel
    click_on "Cancel"
  end
end
