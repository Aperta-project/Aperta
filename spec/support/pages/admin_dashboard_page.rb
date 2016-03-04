class AdminDashboardPage < Page
  text_assertions :journal_name, '.journal-thumbnail-name'

  def self.path
    "/admin"
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
    page.has_css?('.journal-thumbnail-name', text: name)
  end

  def has_journal_names?(*names)
    names.all? { |name_text| has_journal_name? name_text }
  end

  def has_journal_description?(description)
    page.has_css? '.journal-thumbnail-show p', text: description
  end

  def has_journal_descriptions?(*descriptions)
    descriptions.all? { |description| has_journal_description?(description) }
  end

  def has_journal_paper_count?(count)
    count_text = count == 1 ? "#{count} article" : "#{count} articles"
    find('.journal-thumbnail-paper-count', text: count_text)
  end

  def has_journal_paper_counts?(*counts)
    counts.all? { |count| has_journal_paper_count?(count) }
  end

  def create_journal
    click_on 'Add new journal'
    EditJournalFragment.new(find '.journal-thumbnail-edit-form')
  end

  def edit_journal(journal_name)
    find('.journal-thumbnail', text: journal_name).find('.edit-icon').click
    EditJournalFragment.new(find '.journal-thumbnail-edit-form')
  end

  def visit_journal(journal)
    click_link(journal.name)
    JournalPage.new
  end

  def search(query)
    find(".admin-user-search-input").set(query)
    find(".admin-user-search-button").click
  end

  def search_results
    session.has_content? 'Username'
    all('.admin-users .user-row').map do |el|
      Hash[[:first_name, :last_name, :username].zip(UserRowInSearch.new(el).row_content.map &:text)]
    end
  end

  def first_search_result
    session.has_content? 'Username'
    UserRowInSearch.new(all('.admin-users .user-row').first, context: page)
  end

  def attach_and_upload_cover_image(journal, file_name)
    upload_file(element_id: "epub-cover-upload",
                file_name: file_name,
                sentinel: Proc.new{ journal.reload.epub_cover.blank? })
  end
end

class UserRowInSearch < PageFragment
  def row_content
    find_all('td')
  end

  def edit_user_details
    click
    session.has_content? 'User Details'
    EditModal.new(context.find('.user-detail-overlay'), context: context)
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
    wait_for_ajax
    AdminDashboardPage.new(context: context)
  end

  def cancel
    find('.cancel-link').click
    AdminDashboardPage.new(context: context)
  end

  def reset_password
    find('.reset-password-link').click
  end

  def reset_password_status
    find('.reset-password .success')
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
    session.has_content? @name
  end

  def cancel
    click_on "Cancel"
  end
end
