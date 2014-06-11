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
    all('.journal-name').map(&:text)
  end

  def visit_journal(journal)
    click_link(journal.name)
    JournalPage.new
  end
end
