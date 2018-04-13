# coding: utf-8

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

FactoryGirl.define do
  factory :letter_template do
    scenario 'Decision'
    to 'author@example.com'
    subject 'Your [JOURNAL_NAME] submission'

    sequence(:name) { |n| "Some Decision #{n}" }
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
      scenario 'Manuscript'
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
      scenario 'Manuscript'
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

    trait(:academic_editor_invite) do
      scenario 'Invitation'
      ident 'academic-editor-invite'
      name 'Academic Editor Invite'
      to '{{ manuscript.creator.email }}'
      subject 'You have been invited as a reviewer for the manuscript, "{{ manuscript.title }}"'
      body <<-TEXT.strip_heredoc
            <p>I am writing to seek your advice as the academic editor on a manuscript entitled '{{ manuscript.title }}'. The corresponding author is {{author.full_name}}, and the manuscript is under consideration at {{ journal.name }}.</p>
            <p>We would be very grateful if you could let us know whether or not you are able to take on this assignment within 24 hours, so that we know whether to await your comments, or if we need to approach someone else. To accept or decline the assignment via our submission system, please use the link below. If you are available to help and have no conflicts of interest, you also can view the entire manuscript via this link.</p>
            <p><a href="dashboard_url">View Invitation</a></p>
            <p>If you do take this assignment, and think that this work is not suitable for further consideration by {{ journal.name }}, please tell us if it would be more appropriate for one of the other PLOS journals, and in particular, PLOS ONE (<a href="http://plos.io/1hPjumI">http://plos.io/1hPjumI</a>). If you suggest PLOS ONE, please let us know if you would be willing to act as Academic Editor there. For more details on what this role would entail, please go to <a href="http://journals.plos.org/plosone/s/journal-information ">http://journals.plos.org/plosone/s/journal-information</a>.</p>
            <p>I have appended further information, including a copy of the abstract and full list of authors below.</p>
            <p>My colleagues and I are grateful for your support and advice. Please don't hesitate to contact me should you have any questions.</p>
            <p>Kind regards,</p>
            <p>{{ inviter.full_name }}</p>
            <p>{{ journal.name }}</p>
            <p>***************** CONFIDENTIAL *****************</p>
            <p>{{ manuscript.paper_type }}</p>
            <p>Manuscript Title:<br>
            {{ manuscript.title }}</p>
            <p>Authors:<br>
            {% for author in manuscript.authors %}
            {{ forloop.index }}. {{ author.last_name }}, {{ author.first_name }}<br>
            {% endfor %}</p>
            <p>Abstract:<br>
            {{ manuscript.abstract | default: 'Abstract is not available' }}</p>
            <p>To view this manuscript, please use the link presented above in the body of the e-mail.</p>
            <p>You will be directed to your dashboard in Aperta, where you will see your invitation. Selecting "yes" confirms your assignment as Academic Editor. Selecting "yes" to accept this assignment will allow you to access the full submission from the Dashboard link in your main menu.</p>
          TEXT
    end

    trait(:reviewer_invite) do
      scenario 'Invitation'
      ident 'reviewer-invite'
      name 'Reviewer Invite'
      to '{{ manuscript.creator.email }}'
      subject 'You have been invited as a reviewer for the manuscript, "{{ manuscript.title }}"'
      body <<-TEXT.strip_heredoc
            <p>You've been invited as a Reviewer on "{{ manuscript.title }}", for {{ journal.name }}.</p>
            <p>The abstract is included below. We would ideally like to have reviews returned to us within {{ invitation.due_in_days }} days. If you require additional time, please do let us know so that we may plan accordingly.</p>
            <p>Please only accept this invitation if you have no conflicts of interest. If in doubt, please feel free to contact us for advice. If you are unable to review this manuscript, we would appreciate suggestions of other potential reviewers.</p>
            <p>We look forward to hearing from you.</p>
            <p>Sincerely,</p>
            <p>{{ journal.name }} Team</p>
            <p>***************** CONFIDENTIAL *****************</p>
            <p>{{ manuscript.paper_type }}</p>
            <p>Manuscript Title:<br>
            {{ manuscript.title }}</p>
            <p>Authors:<br>
            {% for author in manuscript.authors %}
            {{ forloop.index }}. {{ author.last_name }}, {{ author.first_name }}<br>
            {% endfor %}</p>
            <p>Abstract:<br>
            {{ manuscript.abstract | default: 'Abstract is not available' }}</p>
          TEXT
    end

    trait(:reviewer_welcome) do
      scenario 'Reviewer Report'
      ident 'reviewer-welcome'
      name 'Reviewer Welcome'
      to '{{ reviewer.email }}'
      subject 'Thank you for agreeing to review for {{ journal.name }}'
      body <<-TEXT.strip_heredoc
          <h1>Thank you for agreeing to review for {{ journal.name }}</h1>
          <p>Hello {{ reviewer.full_name }},</p>
          <p>Thank you very much for agreeing to review the manuscript "{{ manuscript.title }}" for {{ journal.name }}.</p>
          <p>In the interest of returning timely decisions to the authors, please return your review by {{ review.due_at_with_minutes }}. Please do let us know if you wish to request additional time to review this manuscript, so that we may plan accordingly.</p>
          <p>For full reviewer guidelines, including what we look for and how to structure your
            review for PLOS Biology, please visit: <a href="http://journals.plos.org/plosbiology/s/reviewer-guidelines">http://journals.plos.org/plosbiology/s/reviewer-guidelines"</a>.</p>
        TEXT
    end

    trait(:reviewer_accepted) do
      scenario 'Manuscript'
      ident 'reviewer-accepted'
      name 'Reviewer Accepted'
      to '{{ inviter.email }}'
      subject 'Reviewer invitation was accepted on the manuscript, "{{ manuscript.title }}"'
      body <<-TEXT.strip_heredoc
          <p>Hello {{ inviter.full_name }}</p>
          <p>{{ invitee_name_or_email }} has accepted your invitation to review the Manuscript: "{{ manuscript.title }}".</p>
        TEXT
    end

    trait(:reviewer_declined) do
      scenario 'Manuscript'
      ident 'reviewer-declined'
      name 'Reviewer Declined'
      to '{{ inviter.email }}'
      subject 'Reviewer invitation was declined on the manuscript, "{{ manuscript.title }}"'
      body <<-TEXT.strip_heredoc
          <p>Hello {{ inviter.full_name }}</p>
          <p>{{ invitee_name_or_email }} has declined your invitation to review the Manuscript: "{{ manuscript.title }}".</p>
          <p class="decline_reason"><strong>Reason:</strong> {{ invitation.decline_reason }}</p>
          <p class="reviewer_suggestions"><strong>Reviewer Suggestions:</strong> {{ invitation.reviewer_suggestions }}</p>
        TEXT
    end
  end
end
