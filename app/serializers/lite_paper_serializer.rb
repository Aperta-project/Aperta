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

class LitePaperSerializer < AuthzSerializer
  attributes :aarx_doi, :active, :created_at, :editable, :file_type, :id, :journal_id, :manuscript_id,
             :processing, :publishing_state, :related_at_date, :roles, :short_doi, :aarx_link,
             :preprint_doi_suffix, :title, :updated_at, :review_due_at, :review_originally_due_at,
             :preprint_dashboard?

  def related_at_date
    return unless scoped_user.present?
    my_roles.map(&:created_at).sort.last
  end

  def roles
    return unless scoped_user.present?
    object.role_descriptions_for(user: scoped_user)
  end

  def review_due_at
    return unless scope && reviewer_report && reviewer_report.state == 'review_pending'
    @review_due_at ||= reviewer_report.due_at
  end

  def review_originally_due_at
    return unless scope && reviewer_report
    # originally_due_at is only returned if it needs to be displayed
    return if reviewer_report.originally_due_at == review_due_at
    reviewer_report.originally_due_at
  end

  # Only authors of a paper can see the 'preprints' section in the dashboard.
  # We then check if the preprint_posted flag is true and if the current user is also an author of the paper.
  def preprint_dashboard?
    object.preprint_posted? && object.authors.map(&:user_id).include?(current_user.id)
  end

  private

  def my_roles
    @my_roles ||= object.roles_for(user: scoped_user)
  end

  def scoped_user
    scope.presence || options[:user]
  end

  def reviewer_report
    @reviewer_report ||= scope.reviewer_reports_with_tasks.detect { |rr| rr.task.paper_id == id }
  end
end
