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

class ParticipationFactory
  attr_reader :task, :assignee, :assigner
  attr_accessor :notify

  def self.create(task:, assignee:, assigner: nil, notify: true)
    new(task: task, assignee: assignee, assigner: assigner, notify: notify).save
  end

  def initialize(task:, assignee:, assigner:, notify:)
    @task = task
    @assignee = assignee
    @assigner = assigner
    @notify = notify
  end

  def save
    return if task.participants.include?(assignee)
    self.notify = false if self_assigned?
    create_participation
  end

  private

  def create_participation
    # New roles
    task.add_participant(assignee).tap do
      send_notification if notify
      CommentLookManager.sync_task(task)
    end
  end

  def self_assigned?
    assigner == assignee
  end

  def send_notification
    UserMailer.delay.add_participant(assigner.try(:id), assignee.id, task.id)
  end
end
