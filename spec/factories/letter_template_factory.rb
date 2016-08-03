FactoryGirl.define do
  factory :letter_template do
    to 'author@example.com'
    subject 'Your [JOURNAL_NAME] submission'

    text 'Some Decision'
    template_decision ''
    letter <<-LETTER.strip_heredoc
              ***EDIT THIS LETTER BEFORE SENDING****\n\nDear Dr. [Last Name],\n\nSincerely,\n\n[EDITOR NAME]\n[EDITOR TITLE]\nPLOS Biology  \n
           LETTER

    trait(:reject) do
      text 'Editor Decision - Reject After Review'
      template_decision 'reject'
      letter <<-LETTER.strip_heredoc
          ***EDIT THIS LETTER BEFORE SENDING****\n\nDear Dr. [Last Name],\n\nSorry, Reject!.\n\nSincerely,\n\n[EDITOR NAME]\n[EDITOR TITLE]\nPLOS Biology  \n
       LETTER
    end

    trait(:accept) do
      text 'RA- Accept'
      template_decision 'accept'
      letter <<-LETTER.strip_heredoc
          ***EDIT THIS LETTER BEFORE SENDING****\n\nDear Dr. [Last Name],\n\ Accept!.\n\nSincerely,\n\n[EDITOR NAME]\n[EDITOR TITLE]\nPLOS Biology  \n
       LETTER
    end

    trait(:major_revision) do
      text 'Editor Decision - Major Revision'
      template_decision 'major_revision'
      letter <<-LETTER.strip_heredoc
          ***EDIT THIS LETTER BEFORE SENDING****\n\nDear Dr. [Last Name],\n\ Major Revision!\n\nSincerely,\n\n[EDITOR NAME]\n[EDITOR TITLE]\nPLOS Biology  \n
       LETTER
    end

    trait(:minor_revision) do
      text 'Editor Decision - Minor Revision'
      template_decision 'minor_revision'
      letter <<-LETTER.strip_heredoc
          ***EDIT THIS LETTER BEFORE SENDING****\n\nDear Dr. [Last Name],\n\n Minor Revision!\n\nSincerely,\n\n[EDITOR NAME]\n[EDITOR TITLE]\nPLOS Biology  \n
       LETTER
    end
  end
end
