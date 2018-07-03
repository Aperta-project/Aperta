# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
    expect(self).to have_no_css(".admin-workflow-thumbnail-header", text: mmt.paper_type)
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
