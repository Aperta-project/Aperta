class AdminDashboardPage < Page
  def self.path
    "/admin"
  end

  def self.visit
    page.visit path
    new
  end

  def initialize(*args)
    super
    synchronize_content! "Journal Administration"
  end

  def journal_names
    all('.journals .journal').map(&:text)
  end

  def visit_journal(journal)
    click_link(journal.name)
    JournalPage.new
  end
end
