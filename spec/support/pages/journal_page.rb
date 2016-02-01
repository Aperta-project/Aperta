class JournalPage < Page
  text_assertions :mmt_name, ".mmt-thumbnail .mmt-thumbnail-title"

  def self.visit(journal)
    page.visit "/admin/journals/#{journal.id}"
    new
  end

  def initialize(*args)
    super
    session.has_content? 'Manuscript Manager Templates'
  end

  def mmt_names
    find(".mmt-thumbnail", match: :first)
    all(".mmt-thumbnail .mmt-thumbnail-title").map(&:text)
  end

  def mmt_thumbnail(mmt)
    find('.mmt-thumbnail .mmt-thumbnail-title', text: mmt.paper_type)
      .find(:xpath, '..')
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

  def epub_cover
    find('.epub-cover-image a').text
  end

  def add_flow
    within ".admin-roles" do
      first(".admin-role-action-button.fa.fa-pencil").click
      find("input[name='role[canViewFlowManager]']").set(true)
      click_link("Edit Flows")
    end

    find(".control-bar-link-icon").click
  end
end
