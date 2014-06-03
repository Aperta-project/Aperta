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

  def add_role
    find('.permission-header .primary-button').click
    RoleFragment.new(find('table.roles tbody', match: :first))
  end

  def find_role(name)
    RoleFragment.new(find('table.roles tbody', text: name))
  end

  def upload_epub_cover
    session.execute_script "$('#epub-cover-upload').css('position', 'relative')"
    attach_file('epub-cover-upload', Rails.root.join('spec', 'fixtures', 'yeti.jpg'), visible: false)
    session.execute_script "$('#epub-cover-upload').css('position', 'absolute')"
  end

  def update_epub_css css
    click_on 'EDIT EPUB CSS'
    fill_in 'epub-css-content', with: css
    click_on 'Save'
  end

  def view_epub_css
    click_on 'EDIT EPUB CSS'
    find('#epub-css-content').value
  end

  def epub_cover
    find('.epub-cover-image a').text
  end

  def css_saved?
    find('span.save-status').text == "Saved"
  end
end
