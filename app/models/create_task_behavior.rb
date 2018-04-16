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

class CreateTaskBehavior < Behavior
  has_attributes integer: %w[card_id], boolean: %w[duplicates_allowed]
  validates :card_id, presence: true
  validates :duplicates_allowed, inclusion: { in: [true, false] }
  validate :card_available_in_journal

  def call(event)
    card = Card.find card_id

    task_attrs = get_task_attrs(card)
    return if disallowed_duplicate?(event.paper)

    task_opts = create_task_opts(event, card, task_attrs)
    TaskFactory.create(task_attrs[:class], task_opts)
  end

  private

  def create_task_opts(event, card, task_attrs)
    { "completed" => false,
      "title" => task_attrs[:name],
      "phase_id" => event.paper.phases.first.id,
      "body" => [],
      'paper' => event.paper,
      'card_version' => card.latest_published_card_version }
  end

  def get_task_attrs(card)
    # Legacy cards are locked at creation. This is like asking 'card.legacy_card?'
    if card.locked?
      task_class = card.name.constantize
      task_name = task_class::DEFAULT_TITLE
    else
      task_class = CustomCardTask
      task_name = card.name
    end

    { class: task_class, name: task_name }
  end

  def disallowed_duplicate?(paper)
    return false if duplicates_allowed
    Task.joins(card_version: :card)
      .where(cards: { id: card_id })
      .where(paper: paper).exists?
  end

  def card_available_in_journal
    return if errors.present?
    card = Card.find card_id

    return if card.journal_id.in? [journal.id, nil]
    errors.add(:card_id, "The card added to this behavior is not available for the behavior's journal")
  end
end
