namespace :decisions do
  desc 'Add a decision to all papers without one'
  task add_decision_to_papers: :environment do
    papers = Paper.includes(:decisions).where decisions: { id: nil }
    papers.each do |paper|
      paper.decisions.create!
    end

    Invitation.where(decision_id: nil).each do |invitation|
      invitation.decision = invitation.paper.latest_decision
      invitation.save!
      p invitation
    end
  end
end
