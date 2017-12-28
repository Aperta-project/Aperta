require 'support/pages/page'
require 'support/pages/manuscript_manager_template_page'

class JournalPage < Page
  text_assertions :mmt_name, ".admin-workflow-thumbnail .admin-workflow-thumbnail-header"

  def self.visit(journal)
    page.visit "/admin/journals/#{journal.id}"
    new
  end

  def initialize(*args)
    super
    session.has_content? 'Manuscript Manager Templates'
  end

  def mmt_names
    find(".admin-workflow-thumbnail", match: :first)
    all(".admin-workflow-thumbnail .admin-workflow-thumbnail-header").map(&:text)
  end

  def mmt_thumbnail(mmt)
    find('.admin-workflow-thumbnail .admin-workflow-thumbnail-header', text: mmt.paper_type)
      .find(:xpath, '..')
  end

  def visit_mmt(mmt)
    thumb = mmt_thumbnail(mmt)
    thumb.click
    ManuscriptManagerTemplatePage.new
  end

  def delete_mmt(mmt)
    thumb = mmt_thumbnail(mmt)
    thumb.find(:xpath, '../div[@class="admin-workflow-thumbnail-icon"]').click
    find('.admin-workflow-thumbnail-overlay .admin-workflow-thumbnail-delete-button').click
    has_no_css?(".admin-workflow-thumbnail-header", text: mmt.paper_type)
    self
  end

  def add_role
    find('.admin-add-new-role-button').click
    RoleFragment.new(find('.admin-role.is-editing', match: :first))
  end

  def find_role(name)
    RoleFragment.new(find('.admin-role', text: name))
  end
end
