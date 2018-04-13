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

# This migration comes from supporting_information (originally 20141125222234)
class UpdateTaskTypes < ActiveRecord::Migration
  def up
    execute <<-SQL
    UPDATE tasks SET type = 'SupportingInformation::SupportingInformationTask' WHERE type = 'SupportingInformation::Task';
    UPDATE journal_task_types SET kind = 'SupportingInformation::SupportingInformationTask' WHERE kind =  'SupportingInformation::Task';
    SQL
  end

  def down
    execute <<-SQL
    UPDATE tasks SET type = 'SupportingInformation::Task' WHERE type = 'SupportingInformation::SupportingInformationTask';
    UPDATE journal_task_types SET kind = 'SupportingInformation::Task' WHERE kind =  'SupportingInformation::SupportingInformationTask';
    SQL
  end
end
