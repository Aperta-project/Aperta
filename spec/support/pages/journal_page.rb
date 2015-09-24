class JournalPage < Page
  text_assertions :mmt_name, ".mmt-thumbnail .mmt-thumbnail-title"

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
    find(".mmt-thumbnail", match: :first)
    all(".mmt-thumbnail .mmt-thumbnail-title").map(&:text)
  end

  def mmt_thumbnail(mmt)
    find(".mmt-thumbnail", match: :first)
    all(".mmt-thumbnail").detect do |ele|
      ele.first(".mmt-thumbnail-title", text: mmt.paper_type)
    end
  end

  def visit_mmt(mmt)
    thumb = mmt_thumbnail(mmt)
    thumb.hover
    thumb.find('.fa-pencil').click
    ManuscriptManagerTemplatePage.new
  end

  def delete_mmt(mmt)
    thumb = mmt_thumbnail(mmt)
    thumb.hover
    thumb.find('.fa-trash').click
    find('.mmt-thumbnail-overlay-confirm-destroy .mmt-thumbnail-delete-button').click
    has_no_css?(".mmt-thumbnail-title", text: mmt.paper_type)
    self
  end

  def add_role
    find('.admin-add-new-role-button').click
    RoleFragment.new(find('.admin-role.is-editing', match: :first))
  end

  def find_role(name)
    RoleFragment.new(find('.admin-role', text: name))
  end

  def upload_epub_cover
    attach_file('epub-cover-upload', Rails.root.join('spec', 'fixtures', 'yeti.jpg'), visible: false)
  end

  def update_epub_css css
    find('button', text: 'EDIT EPUB CSS').click
    find('textarea').set css
    click_on 'Save'
  end

  def view_epub_css
    synchronize_content! 'Edit ePub CSS'
    click_on 'Edit ePub CSS'
    find('textarea').value
  end

  def epub_cover
    find('.epub-cover-image a').text
  end

  def epub_css_saved?
    has_css?('.epub-css.save-status', text: "Saved")
  end

  def view_pdf_css
    synchronize_content! 'Edit PDF CSS'
    click_on 'Edit PDF CSS'
    find('textarea').value
  end

  def update_pdf_css css
    find('button', text: 'EDIT PDF CSS').click
    find('textarea').set css
    click_on 'Save'
  end

  def pdf_css_saved?
    has_css?('.pdf-css.save-status', text: "Saved")
  end

  def update_manuscript_css css
    find('button', text: 'EDIT MANUSCRIPT CSS').click
    find('textarea').set css
    click_on 'Save'
  end

  def view_manuscript_css
    synchronize_content! 'Edit Manuscript CSS'
    click_on 'Edit Manuscript CSS'
    find('textarea').value
  end

  def manuscript_css_saved?
    has_css?('.manuscript-css.save-status', text: "Saved")
  end

  def search_user query
    fill_in 'Admin Search Input', with: query
    find('.admin-user-search-button').click
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
    role.find('.token-remove').click
    self
  end

  def add_flow
    within ".admin-roles" do
      first(".admin-role-action-button.fa.fa-pencil").click
      find("input[name='role[canViewFlowManager]']").set(true)
      click_link("Edit Flows")
    end

    find(".control-bar-link-icon").click
  end

  private

  def user_result_row user
    all('tr.user-row').detect { |tr| tr.all('td').first.text == user.username }
  end
end
