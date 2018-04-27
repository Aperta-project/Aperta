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

class AdminJournalSerializer < AuthzSerializer
  attributes :id,
    :name,
    :logo_url,
    :paper_types,
    :pdf_css,
    :manuscript_css,
    :description,
    :paper_count,
    :created_at,
    :msword_allowed,
    :doi_journal_prefix,
    :doi_publisher_prefix,
    :last_doi_issued,
    :links,
    :letter_template_scenarios
  has_many :admin_journal_roles,
           embed: :ids,
           include: true,
           serializer: AdminJournalRoleSerializer
  has_many :journal_task_types, embed: :ids, include: true
  has_many :card_task_types, embed: :ids, include: true

  def paper_count
    object.papers.count
  end

  def admin_journal_roles
    object.roles
  end

  def card_task_types
    CardTaskType.all
  end

  def journal_task_types
    object.journal_task_types.where(system_generated: false)
  end

  def links
    template_path = journal_manuscript_manager_templates_path(object)
    {
      manuscript_manager_templates: template_path,
      cards: journal_cards_path(object)
    }
  end

  def letter_template_scenarios
    TemplateContext.scenarios.map { |name, klass| { name: name, merge_fields: klass.merge_fields } }
  end

  private

  def can_view?
    scope.can?(:administer, object)
  end
end
