namespace :data do
  namespace :migrate do
    desc <<-DESC
      Reassigns attachments which were erroneously assigned to draft decisions
      in APERTA-7093. They should be assigned to the latest _completed_ decision
      instead
    DESC
    task reassign_attachments_to_completed_decisions: :environment do
      DataTransformation::ReassignDecisionAttachments.new.call
    end
  end
end
