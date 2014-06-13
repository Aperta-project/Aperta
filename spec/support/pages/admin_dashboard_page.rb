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

  def edit_journal_name journal, name

  end

  def visit_journal(journal)
    click_link(journal.name)
    JournalPage.new
  end
end
