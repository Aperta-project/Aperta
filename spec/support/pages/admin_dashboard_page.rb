class AdminDashboardPage < Page
  def self.visit
    page.visit "/admin"
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
