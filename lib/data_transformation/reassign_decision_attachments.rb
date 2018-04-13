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

module DataTransformation
  # Reassigns attachments which were erroneously assigned to draft decisions
  # in APERTA-7093. They should be assigned to the latest _completed_ decision
  # instead
  class ReassignDecisionAttachments < Base
    counter :attachments_assigned_to_draft_decisions
    counter :migrated_attachments

    def transform
      DecisionAttachment.find_each do |decision_attachment|
        next if decision_attachment.owner.completed?
        increment_counter(:attachments_assigned_to_draft_decisions)
        true_decision = decision_attachment.owner.paper.last_completed_decision
        assert(
          true_decision.present?,
          "no completed decision for attachment #{decision_attachment.id}"
        )
        decision_attachment.update!(owner: true_decision)
        log("Migrated attachment #{decision_attachment.id}")
        increment_counter(:migrated_attachments)
      end
    end
  end
end
