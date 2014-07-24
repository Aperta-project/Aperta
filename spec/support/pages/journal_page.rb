class JournalPage < Page
  def self.visit(journal)
    page.visit "/admin/journals/#{journal.id}"
    new
  end

  def add_new_template
    find("button", text: "ADD NEW TEMPLATE").click
    ManuscriptManagerTemplatePage.new
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
    find('.template-thumbnail-overlay-confirm-destroy .attachment-delete-button').click
    synchronize_no_content! mmt.paper_type
    self
  end

  def add_role
    find('.admin-add-new-role-button').click
    RoleFragment.new(find('table.roles tbody', match: :first))
  end

  def find_role(name)
    RoleFragment.new(find('table.roles tbody', text: name))
  end

  def upload_epub_cover
    attach_file('epub-cover-upload', Rails.root.join('spec', 'fixtures', 'yeti.jpg'), visible: false)
  end

  def update_epub_css css
    click_on 'Edit ePub CSS'
    find('textarea').set css
    click_on 'Save'
  end

  def view_epub_css
    click_on 'Edit ePub CSS'
    find('textarea').value
  end

  def epub_cover
    find('.epub-cover-image a').text
  end

  def epub_css_saved?
    find('.epub-css span.save-status').text == "Saved"
  end

  def view_pdf_css
    click_on 'Edit PDF CSS'
    find('textarea').value
  end

  def update_pdf_css css
    click_on 'Edit PDF CSS'
    find('textarea').set css
    click_on 'Save'
  end

  def pdf_css_saved?
    find('.pdf-css span.save-status').text == "Saved"
  end

  def update_manuscript_css css
    click_on 'Edit Manuscript CSS'
    find('textarea').set css
    click_on 'Save'
  end

  def view_manuscript_css
    click_on 'Edit Manuscript CSS'
    find('textarea').value
  end

  def manuscript_css_saved?
    find('.manuscript-css span.save-status').text == "Saved"
  end

  def search_user query
    fill_in 'Admin Search Input', with: query
    click_on 'search'
    self
  end

  def assign_role role
    click_on '+'
    fill_in 'add_role', with: role.name
    find('.tt-suggestion').click
    self
  end

  def admin_user_roles user
    user_result_row(user).all('.assigned-role')
                         .map { |role_label| role_label.text }
  end

  def remove_role user, role
    role = user_result_row(user).all('.assigned-role')
                                .detect { |row_label| row_label.text == role.name }
    role.hover
    role.find('.remove-button').click
    self
  end

  private

  def user_result_row user
    all('tr.user-row').detect { |tr| tr.all('td').first.text == user.username }
  end
end
