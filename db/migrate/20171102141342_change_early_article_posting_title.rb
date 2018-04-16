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

class ChangeEarlyArticlePostingTitle < ActiveRecord::Migration
  # rubocop:disable Rails/SkipsModelValidations

  # The existing custom card migrator doesn't change Task and TaskTemplate titles as part
  # of the migration process.  APERTA-10455 renamed the Early Article Posting card to Early Version,
  # and now need to update the existing data.  This issue doesn't affect adding new Early Version tasks
  # directly to the workflow
  def change
    old_title =  'Early Article Posting'
    new_title =  'Early Version'
    Task.where(title: old_title).update_all(title: new_title)
    TaskTemplate.where(title: old_title).update_all(title: new_title)
  end
  # rubocop:enable Rails/SkipsModelValidations
end
