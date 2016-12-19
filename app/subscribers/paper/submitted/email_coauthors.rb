class Paper::Submitted::EmailCoauthors
  def self.call(_event_name, event_data)
    paper = event_data[:record]
    previous_state = paper.previous_changes[:publishing_state][0]

    if previous_state == 'unsubmitted' || previous_state == 'invited_for_full_submission'
      coauthors = paper.all_authors.reject { |author| (author.try(:email) || author.try(:contact_email)) == paper.creator.email }
      coauthors.each do |coauthor|
        UserMailer.delay.notify_coauthor_of_paper_submission(paper.id, coauthor.id, coauthor.class.name)
      end
    end
  end
end
