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

# TaskFactory is the sole class responsible for actually adding new Task
# instances to a paper
class TaskFactory
  attr_reader :task, :task_klass

  def self.create(task_klass, options = {})
    task = new(task_klass, options).save
    task.task_added_to_paper(task.paper)
    task
  end

  def initialize(task_klass, options = {})
    @task_klass = task_klass

    task_options = default_options
                  .merge(options)
                  .except(:creator, :notify)
    @task = task_klass.new(task_options)
  end

  def save
    task.save!
    task
  end

  private

  def default_options
    HashWithIndifferentAccess.new(
      title: task_klass::DEFAULT_TITLE,
    )
  end
end
