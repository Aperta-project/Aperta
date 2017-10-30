FactoryGirl.define do
  factory :letter_template do
    scenario 'TahiStandardTasks::RegisterDecisionScenario'
    to 'author@example.com'
    subject 'Your [JOURNAL_NAME] submission'

    name 'Some Decision'
    category ''
    body <<-LETTER.strip_heredoc
              ***EDIT THIS LETTER BEFORE SENDING****\n\nDear Dr. [Last Name],\n\nSincerely,\n\n[EDITOR NAME]\n[EDITOR TITLE]\nPLOS Biology  \n
           LETTER

    trait(:reject) do
      name 'Editor Decision - Reject After Review'
      category 'reject'
      body <<-LETTER.strip_heredoc
          ***EDIT THIS LETTER BEFORE SENDING****\n\nDear Dr. [Last Name],\n\nSorry, Reject!.\n\nSincerely,\n\n[EDITOR NAME]\n[EDITOR TITLE]\nPLOS Biology  \n
       LETTER
    end

    trait(:accept) do
      name 'RA- Accept'
      category 'accept'
      body <<-LETTER.strip_heredoc
          ***EDIT THIS LETTER BEFORE SENDING****\n\nDear Dr. [Last Name],\n\ Accept!\n publish your manuscript in [JOURNAL NAME]\n\nSincerely,\n\n[EDITOR NAME]\n[EDITOR TITLE]\nPLOS Biology  \n
       LETTER
    end

    trait(:major_revision) do
      name 'Editor Decision - Major Revision'
      category 'major_revision'
      body <<-LETTER.strip_heredoc
          ***EDIT THIS LETTER BEFORE SENDING****\n\nDear Dr. [Last Name],\n\ Major Revision!\n\nPlease email us [JOURNAL STAFF NAME]\n\nSincerely,\n\n[EDITOR NAME]\n[EDITOR TITLE]\nPLOS Biology  \n
       LETTER
    end

    trait(:minor_revision) do
      name 'Editor Decision - Minor Revision'
      category 'minor_revision'
      body <<-LETTER.strip_heredoc
          ***EDIT THIS LETTER BEFORE SENDING****\n\nDear Dr. [Last Name],\n\n Minor Revision!\n\nSincerely,\n\n[EDITOR NAME]\n[EDITOR TITLE]\nPLOS Biology  \n
       LETTER
    end

    trait(:thank_reviewer) do
      ident 'reviewer-appreciation'
      name 'Reviewer Appreciation'
      subject 'Thank you for reviewing {{ journal.name }}'
      body <<-LETTER.strip_heredoc
        <p>Dear {{ reviewer.first_name }} {{ reviewer.last_name }}.</p><p>Kind regards,<br /> {{ journal.name }}</p>
      LETTER
    end

    trait(:notify_initial_submission) do
      scenario 'PaperScenario'
      ident 'notify-initial-submission'
      name 'Notify Initial Submission'
      to '{{ manuscript.creator.email }}'
      subject 'Thank you for submitting to {{ journal.name }}'
      body <<-TEXT.strip_heredoc
          <h1>Thank you for submitting your manuscript, {{ manuscript.title }}, to {{ journal.name }}. Our staff will be in touch with next steps.</h1>
          <p>Dear {{ manuscript.creator.full_name }},</p>
          <p>Thank you for your submission to {{ journal.name }}, which will now be assessed by the editors to determine whether your manuscript meets the criteria for peer review. We may seek advice from an Academic Editor with relevant expertise.</p>
          <p>If our initial evaluation is positive, we will contact you to request statements relating to ethical approval, funding, data and competing interests ahead of initiating peer review. This additional information is required to satisfy PLOS’ policies and will be made available to editors and reviewers. If you anticipate that you will be unavailable during the next week or two, please provide us with an additional person of contact by return email.</p>
          {% if manuscript.preprint_opted_in %}
            <p>Preprint Submission:</p>
            <p>Thank you for choosing to share your manuscript as a preprint. Our staff will review your submission and contact you if your article complies with our preprint policy. Please refer to the editorial staff of your journal to discuss any concerns.</p>
          {% endif %}
          {% if manuscript.preprint_opted_out %}
            <p>Preprint Submission:</p>
            <p>You choose not to share your manuscript as a preprint. If you wish to revisit that decision please contact the editorial staff of your journal.</p>
            <p>Read more about preprints benefits:</p>
            <p><a href="http://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005473">Ten simple rules to consider regarding preprint submission</p>
          {% endif %}
        TEXT
    end

    trait(:notify_submission) do
      scenario 'PaperScenario'
      ident 'notify-submission'
      name 'Notify Submission'
      to '{{ manuscript.creator.email }}'
      subject 'Thank you for submitting your manuscript to {{ journal.name }}'
      body <<-TEXT.strip_heredoc
          <h1>Thank you for submitting your manuscript, {{ manuscript.title }}, to {{ journal.name }}. Our staff will be in touch with next steps.</h1>
          <p>Hello {{ manuscript.creator.full_name }},</p>
          <p>Thank you for submitting your manuscript, {{ manuscript.title }}, to {{ journal.name }}. Your submission is complete, and our staff will be in touch with next steps.</p>
          {% if manuscript.preprint_opted_in %}
            <p>Preprint Submission:</p>
            <p>Thank you for choosing to share your manuscript as a preprint. Our staff will review your submission and contact you if your article complies with our preprint policy. Please refer to the editorial staff of your journal to discuss any concerns.</p>
          {% endif %}
          {% if manuscript.preprint_opted_out %}
            <p>Preprint Submission:</p>
            <p>You choose not to share your manuscript as a preprint. If you wish to revisit that decision please contact the editorial staff of your journal.</p>
            <p>Read more about preprints benefits:</p>
            <p><a href="http://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005473">Ten simple rules to consider regarding preprint submission</p>
          {% endif %}
        TEXT
    end
  end
end
