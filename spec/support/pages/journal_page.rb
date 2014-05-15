class JournalPage < Page
  def self.visit(journal)
    page.visit "/admin/journals/#{journal.id}"
    new
  end

  def initialize(*args)
    super
    synchronize_content! "Manuscript Manager Templates"
  end

  def mmt_names
    all(".template-thumbnail .mmt-title").map(&:text)
  end

  def mmt_thumbnail(mmt)
    find(".template-thumbnail", text: mmt.paper_type)
  end

  def visit_mmt(mmt)
    thumb = mmt_thumbnail(mmt)
    thumb.hover
    thumb.find('.glyphicon-pencil').click
    ManuscriptManagerTemplatePage.new
  end

  def delete_mmt(mmt)
    thumb = mmt_thumbnail(mmt)
    thumb.hover
    thumb.find('.glyphicon-trash').click
    find('.template-thumbnail-overlay-confirm-destroy .figure-delete-button').click
    synchronize_no_content! mmt.paper_type
    self
  end
end
