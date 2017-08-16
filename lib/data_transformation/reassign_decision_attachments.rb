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
