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

class CreateDueDatetimes < ActiveRecord::Migration
  def change
    create_table :due_datetimes do |t|

      # in the future, we want to allow other objects to have due 'dates'
      t.references :due, polymorphic: true, index: true

      t.datetime :due_at

      # this should be set once and never changed.
      t.datetime :originally_due_at
      # the due 'date' can be extended, in which case these would differ

      # this would be valuable if there is ever a need to recompute a due date
      # and for some reason :created_at could not be relied upon.
      # at the moment I cannot think of a scenario where I'm sure that :created_at
      # would be changed (e.g. it should be preserved through a db dump & restore, etc.)
      # t.datetime :set_at

      t.timestamps null: false
    end
  end
end
