# coding: utf-8
# rubocop:disable all

namespace :seed do
  namespace :letter_templates do

    def author_emails
      '{{ manuscript.corresponding_authors | map: "email" | join: "," }}'
    end

    def greeting
      <<-TEXT.strip_heredoc
        Dear {% for author in manuscript.corresponding_authors %}Dr. {{author.last_name}},{% endfor %}
      TEXT
    end

    def signature
      <<-TEXT.strip_heredoc
          {% if manuscript.editor %}
            {{ manuscript.editor.first_name }} {{ manuscript.editor.last_name }}<br/>
            {% if manuscript.editor.title %}
              {{ manuscript.editor.title }}<br/>
            {% endif %}
          {% else %}
            [EDITOR NAME]<br/>
            [EDITOR TITLE]<br/>
          {% endif %}
          {{ journal.name }}
      TEXT
    end

    def reviews
      <<-TEXT.strip_heredoc
          {% if reviews != empty %}
            <p>------------------------------------------------------------------------</p>
            <p>Reviewer Notes:</p>
            {% for review in reviews %}
              {%- if review.status == 'completed' -%}
                ----------<br/>
                <p>Reviewer {{ review.reviewer_number | default '' }}</p>
                {%- for answer in review.answers -%}
                <p>
                  {{ answer.ident }}
                  {{ answer.value }}
                </p>
                {%- endfor -%}
              {% endif %}
            {% endfor %}
          {% endif %}
      TEXT
    end

    def data_policy
      <<-TEXT.strip_heredoc
          <p>------------------------------------------------------------------------</p>
          <p>DATA POLICY: <br />You may be aware of the PLOS Data Policy, which requires that all data be made available without restriction: http://journals.plos.org/plosbiology/s/data-availability. For more information, please also see this editorial: http://dx.doi.org/10.1371/journal.pbio.1001797</p>
          <p>Note that we do not require all raw data. Rather, we ask that all individual quantitative observations that underlie the data summarized in the figures and results of your paper be made available in one of the following forms:</p>
          <p>1) Supplementary files (e.g., excel). Please ensure that all data files are uploaded as 'Supporting Information' and are invariably referred to (in the manuscript, figure legends, and the Description field when uploading your files) using the following format verbatim: S1 Data, S2 Data, etc. Multiple panels of a single or even several figures can be included as multiple sheets in one excel file that is saved using exactly the following convention: S1_Data.xlsx (using an underscore).</p>
          <p>2) Deposition in a publicly available repository. Please also provide the accession code or a reviewer link so that we may view your data before publication.</p>
          <p>Regardless of the method selected, please ensure that you provide the individual numerical values that underlie the summary data displayed in the following figure panels: (e.g. Figs. ....), as they are essential for readers to assess your analysis and to reproduce it. Please also ensure that figure legends in your manuscript include information on where the underlying data can be found.</p>
          <p>Please ensure that your Data Availability card in the submission system accurately describes where your data can be found.</p>
      TEXT
    end


    desc 'Adds default letter-templates for Register Decision to all journals.'
    task populate: :environment do
      Journal.all.each do |journal|

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        LetterTemplate.where(name: 'Editor Decision - Reject After Review', category: 'reject', journal: journal).first_or_initialize.tap do |lt|
          lt.scenario = 'TahiStandardTasks::RegisterDecisionScenario'
          lt.subject = 'Your {{ journal.name }} submission'
          lt.to = author_emails
          lt.body = <<-TEXT.strip_heredoc
            <p>***EDIT THIS LETTER BEFORE SENDING****</p>
            #{greeting}
            <p>Thank you very much for submitting your manuscript "{{ manuscript.title }}" for review by {{ journal.name }}. As with all papers reviewed by the journal, yours was assessed and discussed by the {{ journal.name }} editors. In this case, your article was also assessed by an Academic Editor with relevant expertise and several independent reviewers. Based on the reviews, I regret that we will not be able to accept this manuscript for publication in the journal.</p>
            <p>The reviews are attached, and we hope they may help you should you decide to revise the manuscript for submission elsewhere. I am sorry that we cannot be more positive on this occasion.</p>
            <p>I hope you appreciate the reasons for this decision and will consider {{ journal.name }} for other submissions in the future. Thank you for your support of PLOS and of open access publishing.</p>
            <p>Sincerely,<br/>
              #{signature}
            </p>
            #{reviews}
          TEXT

          lt.save!
        end

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        LetterTemplate.where(name: 'Editor Decision - Reject After Review CJs', category: 'reject', journal: journal).first_or_initialize.tap do |lt|
          lt.scenario = 'TahiStandardTasks::RegisterDecisionScenario'
          lt.subject = 'Your {{ journal.name }} submission'
          lt.to = author_emails
          lt.body = <<-TEXT.strip_heredoc
            <p>***EDIT THIS LETTER BEFORE SENDING****</p>
            #{greeting}
            <p>Thank you very much for submitting your manuscript entitled "{{ manuscript.title }}" for review by {{ journal.name }}. As with all papers reviewed by the journal, yours was assessed and discussed by the {{ journal.name }} editors. In this case, your article was also assessed by an Academic Editor with relevant expertise and several independent reviewers. Based on the reviews, I regret that we will not be able to accept this manuscript for publication in the journal.</p>
            <p>The reviews are attached and we hope they may help you, should you decide to revise the manuscript for submission elsewhere. I am sorry that we cannot be more positive on this occasion.</p>
            <p>While we cannot consider your manuscript for publication in {{ journal.name }}, we very much appreciate your wish to present your work in one of PLOS's open access publications, and we would like to suggest that you consider submitting it to PLOS [**INSERT CJ JOURNAL NAME**]. If you would like the editors of this journal to consider your work please login at the relevant journal submission site (details on all journals and links to submission sites can be found at http://www.plos.org/journals/). Please note that the journals are editorially independent and we cannot submit your article on your behalf.</p>
            <p>Please indicate in your cover letter to the selected journal that the full paper was submitted to and reviewed at {{ journal.name }}.</p>
            <p>Once at the relevant submission site, log in and choose 'Submit Manuscript' from the list of Author Tasks.</p>
            <p>I hope you have found this review process constructive and that you will consider publishing your work in PLOS in future. Thank you for your support of PLOS and of Open Access publishing.</p>
            <p>Sincerely,<br/>
              #{signature}
            </p>
            <br/>
            #{reviews}
          TEXT

          lt.save!
        end

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        LetterTemplate.where(name: 'Editor Decision - Reject After Review ONE', category: 'reject', journal: journal).first_or_initialize.tap do |lt|
          lt.scenario = 'TahiStandardTasks::RegisterDecisionScenario'
          lt.subject = 'Your {{ journal.name }} submission'
          lt.to = author_emails
          lt.body = <<-TEXT.strip_heredoc
            <p>***EDIT THIS LETTER BEFORE SENDING****</p>
            #{greeting}
            <p>Thank you very much for submitting your manuscript entitled "{{ manuscript.title }}" for review by {{ journal.name }}. As with all papers reviewed by the journal, yours was assessed and discussed by the {{ journal.name }} editors. In this case, your article was also assessed by an Academic Editor with relevant expertise and several independent reviewers. Based on the reviews, I regret that we will not be able to accept this manuscript for publication in the journal.</p>
            <p>The reviews are attached, and we hope they may help you should you decide to revise the manuscript for submission elsewhere. I am sorry that we cannot be more positive on this occasion.</p>
            <p>While we cannot consider your manuscript further for publication in {{ journal.name }}, we very much appreciate your wish to present your work in an Open Access publication and so suggest, as an alternative, submitting to PLOS ONE (www.plosone.org).</p>
            <p>PLOS ONE is a peer-reviewed journal that accepts scientifically sound primary research. The review process at PLOS ONE differs from other PLOS journals in that it does not judge the perceived impact of the work or whether this falls within a particular area of research. Rather, it focuses on whether the study has been performed and reported to high scientific and ethical standards, and whether the data support the conclusions. This approach helps to eliminate the rejection cycles that authors commonly encounter when submitting to one journal after another, ultimately speeding the path to publication.</p>
            <p>If you would like the editors of this journal to consider your work please login at the relevant journal submission site (details about the journal and a link to the submission site can be found at http://journals.plos.org/plosone/s/submit-now). Please note that the journals are editorially independent and we cannot submit your article on your behalf. Once at the relevant submission site, log in and choose 'Submit Manuscript' from the list of Author Tasks, selecting the article type 'Research Article'. Please include the {{ journal.name }} decision letter, including all editorial and reviewer comments, in your submission. This letter can be uploaded as an "Other" file in the file inventory of your submission form and will assist the PLOS ONE editors to assess your manuscript as quickly as possible.</p>
            <p>I hope you have found this review process constructive and that you will consider publishing your work in PLOS ONE. Thank you for your support of PLOS and of Open Access publishing. </p>
            <p>Sincerely,<br/>
              #{signature}
            </p>
            <br/>
            #{reviews}
            TEXT

          lt.save!
        end

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        LetterTemplate.where(name: 'Reject After Review ONE', category: 'reject', journal: journal).first_or_initialize.tap do |lt|
          lt.scenario = 'TahiStandardTasks::RegisterDecisionScenario'
          lt.subject = 'Your {{ journal.name }} submission'
          lt.to = author_emails
          lt.body = <<-TEXT.strip_heredoc
            <p>**IF THE MANUSCRIPT HAS NOT BEEN RE-REVIEWED, EDIT THE FIRST PARAGRAPH AS APPROPRIATE**</p>
            #{greeting}
            <p>Thank you very much for submitting your revised manuscript entitled "{{ manuscript.title }}" for review by {{ journal.name }}. As with all papers reviewed by the journal, yours was assessed and discussed by the {{ journal.name }} editors. In this case, your article was also assessed by the Academic Editor who saw the original version [EDIT HERE if not re-reviewed: and by several independent reviewers. Based on the reviews, I regret that we will not be able to accept this manuscript for publication in the journal. As you will see, the reviewers continue to have concerns about [...EDIT HERE....].] These seem to us sufficiently serious that we cannot encourage you to revise the manuscript further.</p>
            <p>The reviews are attached, and we hope they may help you should you decide to revise the manuscript for submission elsewhere. I am sorry that we cannot be more positive on this occasion.</p>
            <p>[ADD THE FOLLOWING IF APPROPRIATE AND ONLY IF THE PAPER IS NOT CLEARLY FLAWED: While we cannot consider your manuscript further for publication in {{ journal.name }}, we very much appreciate your wish to present your work in an Open Access publication and so suggest, as an alternative, submitting to PLOS ONE (www.plosone.org).</p>
            <p>PLOS ONE is a peer-reviewed journal that accepts scientifically sound primary research. The review process at PLOS ONE differs from other PLOS journals in that it does not judge the perceived impact of the work or whether this falls within a particular area of research. Rather, it focuses on whether the study has been performed and reported to high scientific and ethical standards, and whether the data support the conclusions. This approach helps to eliminate the rejection cycles that authors commonly encounter when submitting to one journal after another, ultimately speeding the path to publication.</p>
            <p>If you would like the editors of this journal to consider your work please login at the relevant journal submission site (details about the journal and a link to the submission site can be found at http://journals.plos.org/plosone/s/submit-now). Please note that the journals are editorially independent and we cannot submit your article on your behalf. Once at the relevant submission site, log in and choose 'Submit Manuscript' from the list of Author Tasks, selecting the article type 'Research Article'. Please include the {{ journal.name }} decision letter, including all editorial and reviewer comments, in your submission. This letter can be uploaded as an "Other" file in the file inventory of your submission form and will assist the PLOS ONE editors to assess your manuscript as quickly as possible.</p>
            <p>I hope you have found this review process constructive and that you will consider publishing your work in PLOS ONE.</p>
            <p>Thank you for your support of PLOS and of Open Access publishing.</p>
            <p>Sincerely,<br/>
              #{signature}
            </p>
            <br/>
            #{reviews}
            TEXT

          lt.save!
        end

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        LetterTemplate.where(name: 'Reject After Revision and Re-review ONE', category: 'reject', journal: journal).first_or_initialize.tap do |lt|
          lt.scenario = 'TahiStandardTasks::RegisterDecisionScenario'
          lt.subject = 'Your {{ journal.name }} submission'
          lt.to = author_emails
          lt.body = <<-TEXT.strip_heredoc
            <p>***EDIT THIS LETTER BEFORE SENDING****</p>
            #{greeting}
            <p>Thank you very much for submitting your revised manuscript entitled {{ manuscript.title }} for review by {{ journal.name }}. As with all papers reviewed by the journal, yours was assessed and discussed by the {{ journal.name }} editors. In this case, your article was also assessed by the Academic Editor who saw the original version and by several independent reviewers. Based on the reviews, I regret that we will not be able to accept this manuscript for publication in the journal. As you will see, the reviewers continue to have concerns about [...EDIT HERE....]. These seem to us sufficiently serious that we cannot encourage you to revise the manuscript further.</p>
            <p>The reviews are attached, and we hope they may help you should you decide to revise the manuscript for submission elsewhere. I am sorry that we cannot be more positive on this occasion.</p>
            <p>[ADD THE FOLLOWING IF APPROPRIATE AND ONLY IF THE PAPER IS NOT CLEARLY FLAWED: While we cannot consider your manuscript further for publication in {{ journal.name }}, we very much appreciate your wish to present your work in an Open Access publication and so suggest, as an alternative, submitting to PLOS ONE (www.plosone.org).</p>
            <p>PLOS ONE is a peer-reviewed journal that accepts scientifically sound primary research. The review process at PLOS ONE differs from other PLOS journals in that it does not judge the perceived impact of the work or whether this falls within a particular area of research. Rather, it focuses on whether the study has been performed and reported to high scientific and ethical standards, and whether the data support the conclusions. This approach helps to eliminate the rejection cycles that authors commonly encounter when submitting to one journal after another, ultimately speeding the path to publication.</p>
            <p>If you would like the editors of this journal to consider your work please login at the relevant journal submission site (details about the journal and a link to the submission site can be found at http://journals.plos.org/plosone/s/submit-now). Please note that the journals are editorially independent and we cannot submit your article on your behalf. Once at the relevant submission site, log in and choose 'Submit Manuscript' from the list of Author Tasks, selecting the article type 'Research Article'. Please include the {{ journal.name }} decision letter, including all editorial and reviewer comments, in your submission. This letter can be uploaded as an "Other" file in the file inventory of your submission form and will assist the PLOS ONE editors to assess your manuscript as quickly as possible.</p>
            <p>I hope you have found this review process constructive and that you will consider publishing your work in PLOS ONE.</p>
            <p>Thank you for your support of PLOS and of Open Access publishing.</p>
            <p>Sincerely,<br/>
              #{signature}
            </p>
            <br/>
            #{reviews}
            TEXT

          lt.save!
        end

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        LetterTemplate.where(name: 'RA Major Revision', category: 'major_revision', journal: journal).first_or_initialize.tap do |lt|
          lt.scenario = 'TahiStandardTasks::RegisterDecisionScenario'
          lt.subject = 'A decision has been registered on the manuscript, "{{ manuscript.title }}"'
          lt.to = author_emails
          lt.body = <<-TEXT.strip_heredoc
            <p>**choose appropriate first paragraph; attach prod reqs PDF - DELETE THIS***</p>
            #{greeting}
            <p>***EITHER****</p>
            <p>Thank you very much for submitting your manuscript “{{ manuscript.title }}” for consideration at {{ journal.name }}. Your manuscript has been evaluated by the {{ journal.name }} editorial staff, by an Academic Editor with relevant expertise, and by several independent reviewers.</p>
            <p>****OR (if previous OPEN REJECT)****</p>
            <p>Thank you very much for submitting a revised version of your manuscript \"{{ manuscript.title }}\" for consideration at {{ journal.name }}. This revised version of your manuscript has been evaluated by the {{ journal.name }} editorial staff, an Academic Editor and reviewers.</p>
            <p>****</p>
            <p>In light of the reviews, we will not be able to accept the current version of the manuscript, but we would welcome resubmission of a much-revised version that takes into account the reviewers' comments. We cannot make any decision about publication until we have seen the revised manuscript and your response to the reviewers' comments. Your revised manuscript is also likely to be sent for further evaluation by the reviewers.</p>
            <p>Your revisions should address the specific points made by each reviewer. Please also submit a cover letter and a point-by-point response to all of the reviewers' comments that indicates the changes you have made to the manuscript. You should also cite any additional relevant literature that has been published since the original submission and mention any additional citations in your response.</p>
            <p>Please note that as a condition of publication PLOS’ data policy requires that you make available all data used to draw conclusions in papers published in PLOS journals. If you have not already done so, you must include any data used in your manuscript either in appropriate repositories, within the body of the manuscript, or as supporting information (NB this includes any numerical values that were used to generate graphs, histograms etc.). For an example see here: http://www.plosbiology.org/article/info%3Adoi%2F10.1371%2Fjournal.pbio.1001908#s5.</p>
            <p>Upon resubmission, the editors will assess the advance your revised manuscript represents over work published prior to its resubmission in reaching a decision regarding further consideration. The editors also will assess the revisions you have made and decide whether to consult further with an Academic Editor. If the editors and Academic Editor feel that the revised manuscript remains appropriate for the journal and that the revisions are sufficient to warrant further consideration, we generally will send the manuscript for re-review. We aim to consult the same Academic Editor and reviewers for revised manuscripts but may consult others if needed.</p>
            <p>We expect to receive your revised manuscript within two months. Please email us ({{ journal.staff_email }}) to discuss this if you have any questions or concerns, or would like to request an extension.</p>
            <p>At this stage, your manuscript remains formally under active consideration at our journal. Please note that unless we receive the revised manuscript within this timeframe, your submission may be closed and the manuscript would no longer be ‘under consideration’ at {{ journal.name }}. We will of course be in touch before this action is taken. Please rest assured that this is merely an administrative step - you may still submit your revised submission after your file is closed, but will need to do so as a new submission, referencing the previous tracking number.</p>
            <p>Please notify us by email if you do not wish to revise your manuscript for {{ journal.name }} and instead wish to pursue publication elsewhere, so that we may end consideration of the manuscript at {{ journal.name }}.</p>
            <p>If you do still intend to submit a revised version of your manuscript, please log in at http://www.aperta.tech.  On the ‘Your Manuscripts’ page, click the title of your manuscript to access and edit your submission.</p>
            <p>Before you revise your manuscript, we ask that you please review the following PLOS policy and formatting requirements checklist PDF: https://drive.google.com/file/d/0B_7IflO1bmDTYlZBdmJCT1FUWG8/view?usp=sharing. It’s helpful for you to take a look through this at this stage, and to align your revision with our requirements; should your paper be eventually accepted, this will save everyone time at the acceptance stage.</p>
            <p>Thank you again for your submission to our journal. We hope that our editorial process has been constructive thus far, and we welcome your feedback at any time. Please don't hesitate to contact us if you have any questions or comments.</p>
            <p>Sincerely,<br/>
              #{signature}
            </p>
            <br/>
            #{reviews}
            TEXT

          lt.save!
        end

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        LetterTemplate.where(name: 'RA Minor Revision', category: 'minor_revision', journal: journal).first_or_initialize.tap do |lt|
          lt.scenario = 'TahiStandardTasks::RegisterDecisionScenario'
          lt.subject = 'Your {{ journal.name }} submission'
          lt.to = author_emails
          lt.body = <<-TEXT.strip_heredoc
            <p>** CHOOSE BETWEEN NUMBERED PARAGRAPHS BELOW **</p>
            <p>** REMOVE THIS TEXT BEFORE SENDING **</p>
            #{greeting}
            <p>[1] <br />Thank you very much for submitting your manuscript "{{ manuscript.title }}" for review by {{ journal.name }}. As with all papers reviewed by the journal, yours was seen by the PLOS editorial staff as well as by an Academic Editor with relevant expertise. In this case, your article was also evaluated by independent reviewers. The reviewers appreciated the attention to an important topic. Based on the reviews, we will probably accept this manuscript for publication, providing that you are willing and able to modify the manuscript according to the review recommendations.</p>
            <p>[2]<br />Thank you for submitting your revised manuscript entitled "{{ manuscript.title }}" for publication in {{ journal.name }}. I have now obtained advice from the original reviewers and have discussed their comments with the Academic Editor.</p>
            <p>******* DELETE AS APPROPRIATE &ndash; TWO LARGE SECTIONS TO CHOOSE BETWEEN</p>
            <p>EITHER [3]:<br />Based on the reviews, we will probably accept this manuscript for publication, assuming that you are willing and able to modify the manuscript to address the remaining concerns raised by the reviewers.</p>
            <p>***Insert Editorial Requirements and INCLUDE DATA REQUIREMENTS AS NECESSARY***</p>
            <p>We expect to receive your revised manuscript within two weeks. Your revisions should address the specific points made by each reviewer. In addition to the remaining revisions and before we will be able to formally accept your manuscript and consider it "in press", we also need to ensure that your article conforms to our guidelines. A member of our team will be in touch shortly with a set of requests regarding the manuscript files. As we can&rsquo;t proceed until these requirements are met, your swift response will help prevent delays to publication.</p>
            <p>OR [4]: <br />We&rsquo;re delighted to let you know that we're now editorially satisfied with your manuscript, however before we can formally accept your manuscript and consider it "in press", we also need to ensure that your article conforms to our guidelines. A member of our team will be in touch shortly with a set of requests regarding the manuscript files. As we can&rsquo;t proceed until these requirements are met, your swift response will help prevent delays to publication. <br />******* <br /><br />Upon acceptance of your article, your final files will be copyedited and typeset into the final PDF. While you will have an opportunity to review these files as proofs, PLOS will only permit corrections to spelling or significant scientific errors. Therefore, please take this final revision time to assess and make any remaining major changes to your manuscript.</p>
            <p>To submit your revision, please log in at http://www.aperta.tech. Click the title of your manuscript from the Your Manuscripts page to access and edit your submission. Your revised submission must include a cover letter, and a Response to Reviewers that provides a detailed response to the reviewers' comments (if applicable) and indication of any changes that you have made to the manuscript.</p>
            <p>Please do not hesitate to contact me should you have any questions.</p>
            <p>Sincerely,<br/>
              #{signature}
            </p>
            #{data_policy}
            #{reviews}
            TEXT

          lt.save!
        end

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        LetterTemplate.where(name: 'RA Accept', category: 'accept', journal: journal).first_or_initialize.tap do |lt|
          lt.scenario = 'TahiStandardTasks::RegisterDecisionScenario'
          lt.subject = 'Your {{ journal.name }} submission'
          lt.to = author_emails
          lt.body = <<-TEXT.strip_heredoc
            <p>***EDIT THIS LETTER BEFORE SENDING****</p>
            #{greeting}
            <p>On behalf of my colleagues and the Academic Editor, [*INSERT AE'S NAME*], I am pleased to inform you that we will be delighted to publish your manuscript in {{ journal.name }}.</p>
            <p>Please note that since your article will appear in the magazine section of the journal you will not be charged for publication.</p>
            <p>The files will now enter our production system. In one-two weeks' time, you should receive a copyedited version of the manuscript, along with your figures for a final review. You will be given two business days to review and approve the copyedit. Then, within a week, you will receive a PDF proof of your typeset article. You will have two days to review the PDF and make any final corrections. If there is a chance that you'll be unavailable during the copy editing/proof review period, please provide us with contact details of one of the other authors whom you nominate to handle these stages on your behalf. This will ensure that any requested corrections reach the production department in time for publication.</p>
            <p>PRESS</p>
            <p>We frequently collaborate with communication and public information offices. If your institution is planning to promote your findings, we would be grateful if they could coordinate with biologypress@plos.org.</p>
            <p>We also ask that you take this opportunity to read our Embargo Policy regarding the discussion, promotion and media coverage of work that is yet to be published by PLOS. As your manuscript is not yet published, it is bound by the conditions of our Embargo Policy. Please be aware that this policy is in place both to ensure that any press coverage of your article is fully substantiated and to provide a direct link between such coverage and the published work. For full details of our Embargo Policy, please visit http://www.plos.org/about/media-inquiries/embargo-policy/.</p>
            <p>Please don't hesitate to contact me should you have any questions.</p>
            <p>Kind regards, <br />
              [*INSERT NAME*]<br />
              Publications Assistant<br />
              {{ journal.name }}
            </p>
            <p>On Behalf of<br />
              [*HANDLING EDITOR*]<br />
              [*HANDLING EDITOR POSITION*]<br />
              {{ journal.name }}
            </p>
            TEXT

          lt.save!
        end

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        LetterTemplate.where(name: 'Review Reminder - Before Due', journal: journal).first_or_initialize.tap do |lt|
          lt.scenario = 'ReviewerReportScenario'
          lt.subject = 'Your review for {{ journal.name }} is due soon'
          lt.body = <<-TEXT.strip_heredoc
            <p>Dear Dr. {{ reviewer.last_name }}</p>
            <p>Thank you again for agreeing to review “{{ manuscript.title }}” for {{ journal.name }}. This is a brief reminder that we hope to receive your review comments on the manuscript by {{ review.due_at }}. Please let us know as soon as possible, by return email, if your review will be delayed.</p>
            <p>To view the manuscript and submit your review, please log in to Aperta via the green button below.</p>
            <p>For further instructions, please see the Aperta Reviewer Guide here: <a href="http://plos.io/Aperta-Reviewers">http://plos.io/Aperta-Reviewers</a></p>
            <p>We are grateful for your continued support of {{ journal.name }}. Please do not hesitate to contact the journal office if you have questions or require assistance.</p>
            TEXT

          lt.save!
        end

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        LetterTemplate.where(name: 'Review Reminder - First Late', journal: journal).first_or_initialize.tap do |lt|
          lt.scenario = 'ReviewerReportScenario'
          lt.subject = 'Late Review for {{ journal.name }}'
          lt.body = <<-TEXT.strip_heredoc
            <p>Dear Dr. {{ reviewer.last_name }}</p>
            <p>This is a reminder that your review of the PLOS Biology manuscript “{{ manuscript.title }}” was due to be received by  {{ review.due_at }}.</p>
            <p>As your review was due two days ago, we would be grateful if you could provide us with your comments as soon as possible. If you are busy and unable to complete your review in this timeframe, please let us know by return email so that we may plan accordingly.</p>
            <p>To view the manuscript and submit your review, please log in to Aperta via the green button below.</p>
            <p>For further instructions, please see the Aperta Reviewer Guide here: <a href="http://plos.io/Aperta-Reviewers">http://plos.io/Aperta-Reviewers</a></p>
            <p>We are grateful for your continued support of {{ journal.name }}. Please do not hesitate to contact the journal office if you have questions or require assistance.</p>
            TEXT

          lt.save!
        end

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        LetterTemplate.where(name: 'Review Reminder - Second Late', journal: journal).first_or_initialize.tap do |lt|
          lt.scenario = 'ReviewerReportScenario'
          lt.subject = 'Reminder of Late Review for {{ journal.name }}'
          lt.body = <<-TEXT.strip_heredoc
            <p>Dear Dr. {{ reviewer.last_name }}</p>
            <p>This is a reminder that your review of the PLOS Biology manuscript “{{ manuscript.title }}” was expected by the agreed due date, {{ review.due_at }}. At this stage we urgently need the review in order to proceed with the editorial process.</p>
            <p>We would appreciate it if you can submit your review as soon as possible so that we can move this manuscript to a decision for the authors. If you need assistance or are experiencing delays, please let us know by return email.</p>
            <p>To view the manuscript and submit your review, please log in to Aperta via the green button below.</p>
            <p>For further instructions, please see the Aperta Reviewer Guide here: <a href="http://plos.io/Aperta-Reviewers">http://plos.io/Aperta-Reviewers</a></p>
            <p>We are grateful for your continued support of {{ journal.name }}. Please do not hesitate to contact the journal office if you have questions or require assistance.</p>
            TEXT

          lt.save!
        end

        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        LetterTemplate.where(name: 'Reviewer Appreciation', journal: journal).first_or_initialize.tap do |lt|
          lt.scenario = 'ReviewerReportScenario'
          lt.subject = 'Thank you for reviewing for {{ journal.name }}'
          lt.body = <<-TEXT.strip_heredoc
          <p>Dear {{ reviewer.first_name }} {{ reviewer.last_name }},</p>
          <p>Thank you for taking the time to review the manuscript “{{ manuscript.title }}”, for {{ journal.name }}.
          We greatly appreciate your assistance with the review process, especially given the many competing demands on your time.</p>
          <p>Thank you for your continued support of {{ journal.name }}, we look forward to working with you again in the future.
          If you have any questions or feedback, please do not hesitate to contact us at {{ journal.staff_email }}.</p>
          TEXT

          lt.save!
        end
      end
    end
  end
end
