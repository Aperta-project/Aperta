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

class TaskCompletionBehavior < Behavior
  CHANGE_TO = %w[completed incomplete toggle].freeze

  has_attributes integer: %w[card_id], string: %w[change_to]
  # rubocop:disable Style/FormatStringToken
  validates :card_id, presence: true, inclusion: { in: ->(_) { Card.pluck(:id) }, message: '%{value} is not a valid card id' }
  validates :change_to, presence: true, inclusion: { in: CHANGE_TO, message: "%{value} should be one of the following: #{CHANGE_TO}" }

  def call(event)
    # load card
    card = Card.find(card_id)

    # load the task
    tasks = event.paper.tasks.where(card_version_id: card.card_versions.pluck(:id))

    tasks.each do |task|
      case change_to
      when 'toggle'
        task.completed = !task.completed
      when 'completed'
        task.completed = true
      when 'incomplete'
        task.completed = false
      end
      task.notify_requester = true
      task.save!
    end
  end
end
