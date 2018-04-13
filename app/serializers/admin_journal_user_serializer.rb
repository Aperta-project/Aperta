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

class AdminJournalUserSerializer < AuthzSerializer
  attributes :id,
             :username,
             :first_name,
             :last_name

  has_many :user_roles, embed: :ids, include: true
  has_many :admin_journal_roles, embed: :ids, include: true

  def user_roles
    if @options[:journal].present?
      object.roles.where(journal: @options[:journal],
                         participates_in_papers: true,
                         participates_in_tasks: true)
    else
      object.roles.where(participates_in_papers: true,
                         participates_in_tasks: true)
    end
  end

  def admin_journal_roles
    if @options[:journal].present?
      object.roles.where(journal: @options[:journal],
                         participates_in_papers: false,
                         participates_in_tasks: false)
    else
      object.roles
    end
  end

  private

  def can_view?
    return false if @options[:journal].blank?
    scope.can?(:administer, @options[:journal])
  end
end
