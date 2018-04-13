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

class RemovePlosAuthors < ActiveRecord::Migration
  def up

    # migrate `plos_authors` data to `authors`
    attribute_sql = %Q{
      UPDATE authors
      SET
        middle_initial        = plos_authors.middle_initial,
        email                 = plos_authors.email,
        department            = plos_authors.department,
        title                 = plos_authors.title,
        corresponding         = plos_authors.corresponding,
        deceased              = plos_authors.deceased,
        affiliation           = plos_authors.affiliation,
        secondary_affiliation = plos_authors.secondary_affiliation,
        contributions         = plos_authors.contributions,
        ringgold_id           = plos_authors.ringgold_id,
        secondary_ringgold_id = plos_authors.secondary_ringgold_id
      FROM plos_authors_plos_authors as plos_authors
      WHERE plos_authors.id = authors.actable_id;
    }
    ActiveRecord::Base.connection.execute(attribute_sql)

    # update existing tasks to new model name
    task_sql = %Q{
      UPDATE tasks
      SET type = 'TahiStandardTasks::AuthorsTask'
      WHERE type = 'PlosAuthors::PlosAuthorsTask'
    }
    ActiveRecord::Base.connection.execute(task_sql)
  end

  def down
    # noop
  end
end
