# rubocop:disable all

namespace :seed do
  namespace :letter_templates do
    desc 'Adds default letter-templates for Register Decision to all journals. First template_decision is default'
    task populate: :environment do
      Journal.all.each do |journal|

        text   = 'Editor Decision - Reject After Review'
        letter = <<-TEXT.strip_heredoc
          ***EDIT THIS LETTER BEFORE SENDING****

          Dear Dr. [LAST NAME],

          Thank you very much for submitting your manuscript '[PAPER TITLE]' for review by PLOS Biology. As with all papers reviewed by the journal, yours was assessed and discussed by the PLOS Biology editors. In this case, your article was also assessed by an Academic Editor with relevant expertise and several independent reviewers. Based on the reviews, I regret that we will not be able to accept this manuscript for publication in the journal.

          The reviews are attached, and we hope they may help you should you decide to revise the manuscript for submission elsewhere. I am sorry that we cannot be more positive on this occasion. 

          I hope you appreciate the reasons for this decision and will consider PLOS Biology for other submissions in the future. Thank you for your support of PLOS and of open access publishing.

          Sincerely,

          [EDITOR NAME]
          [EDITOR TITLE]
          PLOS Biology  
          TEXT
        subject = 'Your [JOURNAL NAME] submission'
        to_field = '[AUTHOR EMAIL]'
        template = LetterTemplate.where(template_decision: 'reject', text: text, journal: journal).first_or_create!
        template.update_attributes(to: to_field, subject: subject, letter: letter)

        text   = 'Editor Decision - Reject After Review CJs'
        letter = <<-TEXT.strip_heredoc
          ***EDIT THIS LETTER BEFORE SENDING****

          Dear Dr. [LAST NAME],

          Thank you very much for submitting your manuscript entitled '[PAPER TITLE]' for review by PLOS Biology. As with all papers reviewed by the journal, yours was assessed and discussed by the PLOS Biology editors. In this case, your article was also assessed by an Academic Editor with relevant expertise and several independent reviewers. Based on the reviews, I regret that we will not be able to accept this manuscript for publication in the journal.

          The reviews are attached and we hope they may help you, should you decide to revise the manuscript for submission elsewhere. I am sorry that we cannot be more positive on this occasion. 

          While we cannot consider your manuscript for publication in PLOS Biology, we very much appreciate your wish to present your work in one of PLOS's open access publications, and we would like to suggest that you consider submitting it to PLOS [**INSERT CJ JOURNAL NAME**]. If you would like the editors of this journal to consider your work please login at the relevant journal submission site (details on all journals and links to submission sites can be found at http://www.plos.org/journals/). Please note that the journals are editorially independent and we cannot submit your article on your behalf.

          Please indicate in your cover letter to the selected journal that the full paper was submitted to and reviewed at PLOS Biology. 

          Once at the relevant submission site, log in and choose 'Submit Manuscript' from the list of Author Tasks.   

          I hope you have found this review process constructive and that you will consider publishing your work in PLOS in future.  Thank you for your support of PLOS and of Open Access publishing.

          Sincerely,

          [EDITOR NAME]
          [EDITOR TITLE]
          PLOS Biology


          Reviewer notes:

          [REVIEWER COMMENTS]
          TEXT
        subject = 'Your [JOURNAL NAME] submission'
        to_field = '[AUTHOR EMAIL]'
        template = LetterTemplate.where(template_decision: 'reject', text: text, journal: journal).first_or_create!
        template.update_attributes(to: to_field, subject: subject, letter: letter)

        text   = 'Editor Decision - Reject After Review ONE'
        letter = <<-TEXT.strip_heredoc
          ***EDIT THIS LETTER BEFORE SENDING****

          Dear Dr. [LAST NAME],

          Thank you very much for submitting your manuscript entitled “[PAPER TITLE]” for review by PLOS Biology. As with all papers reviewed by the journal, yours was assessed and discussed by the PLOS Biology editors. In this case, your article was also assessed by an Academic Editor with relevant expertise and several independent reviewers. Based on the reviews, I regret that we will not be able to accept this manuscript for publication in the journal.

          The reviews are attached, and we hope they may help you should you decide to revise the manuscript for submission elsewhere. I am sorry that we cannot be more positive on this occasion.

          While we cannot consider your manuscript further for publication in PLOS Biology, we very much appreciate your wish to present your work in an Open Access publication and so suggest, as an alternative, submitting to PLOS ONE (www.plosone.org).

          PLOS ONE is a peer-reviewed journal that accepts scientifically sound primary research. The review process at PLOS ONE differs from other PLOS journals in that it does not judge the perceived impact of the work or whether this falls within a particular area of research. Rather, it focuses on whether the study has been performed and reported to high scientific and ethical standards, and whether the data support the conclusions. This approach helps to eliminate the rejection cycles that authors commonly encounter when submitting to one journal after another, ultimately speeding the path to publication.

          If you would like the editors of this journal to consider your work please login at the relevant journal submission site (details about the journal and a link to the submission site can be found at http://journals.plos.org/plosone/s/submit-now). Please note that the journals are editorially independent and we cannot submit your article on your behalf. Once at the relevant submission site, log in and choose 'Submit Manuscript' from the list of Author Tasks, selecting the article type 'Research Article'. Please include the PLOS Biology decision letter, including all editorial and reviewer comments, in your submission. This letter can be uploaded as an “Other” file in the file inventory of your submission form and will assist the PLOS ONE editors to assess your manuscript as quickly as possible.

          I hope you have found this review process constructive and that you will consider publishing your work in PLOS ONE.  Thank you for your support of PLOS and of Open Access publishing.

          Sincerely,

          [EDITOR NAME]
          [EDITOR TITLE]
          PLOS Biology


          Reviewer notes:

          [REVIEWER COMMENTS]
          TEXT
        subject = 'Your [JOURNAL NAME] submission'
        to_field = '[AUTHOR EMAIL]'
        template = LetterTemplate.where(template_decision: 'reject', text: text, journal: journal).first_or_create!
        template.update_attributes(to: to_field, subject: subject, letter: letter)

        text   = 'Reject After Review ONE'
        letter = <<-TEXT.strip_heredoc
          **IF THE MANUSCRIPT HAS NOT BEEN RE-REVIEWED, EDIT THE FIRST PARAGRAPH AS APPROPRIATE**

          Dear Dr. [LAST NAME],

          Thank you very much for submitting your revised manuscript entitled “[PAPER TITLE]” for review by PLOS Biology. As with all papers reviewed by the journal, yours was assessed and discussed by the PLOS Biology editors. In this case, your article was also assessed by the Academic Editor who saw the original version [EDIT HERE if not re-reviewed: and by several independent reviewers. Based on the reviews, I regret that we will not be able to accept this manuscript for publication in the journal. As you will see, the reviewers continue to have concerns about [...EDIT HERE....].] These seem to us sufficiently serious that we cannot encourage you to revise the manuscript further. 

          The reviews are attached, and we hope they may help you should you decide to revise the manuscript for submission elsewhere. I am sorry that we cannot be more positive on this occasion. 

          [ADD THE FOLLOWING IF APPROPRIATE AND ONLY IF THE PAPER IS NOT CLEARLY FLAWED:  While we cannot consider your manuscript further for publication in PLOS Biology, we very much appreciate your wish to present your work in an Open Access publication and so suggest, as an alternative, submitting to PLOS ONE (www.plosone.org). 

          PLOS ONE is a peer-reviewed journal that accepts scientifically sound primary research. The review process at PLOS ONE differs from other PLOS journals in that it does not judge the perceived impact of the work or whether this falls within a particular area of research. Rather, it focuses on whether the study has been performed and reported to high scientific and ethical standards, and whether the data support the conclusions. This approach helps to eliminate the rejection cycles that authors commonly encounter when submitting to one journal after another, ultimately speeding the path to publication.

          If you would like the editors of this journal to consider your work please login at the relevant journal submission site (details about the journal and a link to the submission site can be found at http://journals.plos.org/plosone/s/submit-now). Please note that the journals are editorially independent and we cannot submit your article on your behalf. Once at the relevant submission site, log in and choose 'Submit Manuscript' from the list of Author Tasks, selecting the article type 'Research Article'. Please include the PLOS Biology decision letter, including all editorial and reviewer comments, in your submission. This letter can be uploaded as an “Other” file in the file inventory of your submission form and will assist the PLOS ONE editors to assess your manuscript as quickly as possible.

          I hope you have found this review process constructive and that you will consider publishing your work in PLOS ONE.]  

          Thank you for your support of PLOS and of Open Access publishing.

          Sincerely,

          [EDITOR NAME]
          [EDITOR TITLE]
          PLOS Biology


          Reviewer notes:

          [REVIEWER COMMENTS]
          TEXT
        subject = 'Your [JOURNAL NAME] submission'
        to_field = '[AUTHOR EMAIL]'
        template = LetterTemplate.where(template_decision: 'reject', text: text, journal: journal).first_or_create!
        template.update_attributes(to: to_field, subject: subject, letter: letter)

        text   = 'Reject After Revision and Re-review ONE'
        letter = <<-TEXT.strip_heredoc
          Dear Dr. [LAST NAME],

          Thank you very much for submitting your revised manuscript entitled [PAPER TITLE] for review by PLOS Biology. As with all papers reviewed by the journal, yours was assessed and discussed by the PLOS Biology editors. In this case, your article was also assessed by the Academic Editor who saw the original version and by several independent reviewers. Based on the reviews, I regret that we will not be able to accept this manuscript for publication in the journal. As you will see, the reviewers continue to have concerns about [...EDIT HERE....]. These seem to us sufficiently serious that we cannot encourage you to revise the manuscript further.  

          The reviews are attached, and we hope they may help you should you decide to revise the manuscript for submission elsewhere. I am sorry that we cannot be more positive on this occasion. 

          [ADD THE FOLLOWING IF APPROPRIATE AND ONLY IF THE PAPER IS NOT CLEARLY FLAWED:  While we cannot consider your manuscript further for publication in PLOS Biology, we very much appreciate your wish to present your work in an Open Access publication and so suggest, as an alternative, submitting to PLOS ONE (www.plosone.org). 

          PLOS ONE is a peer-reviewed journal that accepts scientifically sound primary research. The review process at PLOS ONE differs from other PLOS journals in that it does not judge the perceived impact of the work or whether this falls within a particular area of research. Rather, it focuses on whether the study has been performed and reported to high scientific and ethical standards, and whether the data support the conclusions. This approach helps to eliminate the rejection cycles that authors commonly encounter when submitting to one journal after another, ultimately speeding the path to publication.

          If you would like the editors of this journal to consider your work please login at the relevant journal submission site (details about the journal and a link to the submission site can be found at http://journals.plos.org/plosone/s/submit-now). Please note that the journals are editorially independent and we cannot submit your article on your behalf. Once at the relevant submission site, log in and choose 'Submit Manuscript' from the list of Author Tasks, selecting the article type 'Research Article'. Please include the PLOS Biology decision letter, including all editorial and reviewer comments, in your submission. This letter can be uploaded as an “Other” file in the file inventory of your submission form and will assist the PLOS ONE editors to assess your manuscript as quickly as possible.

          I hope you have found this review process constructive and that you will consider publishing your work in PLOS ONE.]  

          Thank you for your support of PLOS and of Open Access publishing.

          Sincerely,

          [EDITOR NAME]
          [EDITOR TITLE]
          PLOS Biology


          Reviewer notes:

          [REVIEWER COMMENTS]
          TEXT
        subject = 'Your [JOURNAL NAME] submission'
        to_field = '[AUTHOR EMAIL]'
        template = LetterTemplate.where(template_decision: 'reject', text: text, journal: journal).first_or_create!
        template.update_attributes(to: to_field, subject: subject, letter: letter)

        text   = 'RA Major Revision'
        letter = <<-TEXT.strip_heredoc
          **choose appropriate first paragraph; attach prod reqs PDF - DELETE THIS***

          Dear Dr. [LAST NAME],

          ***EITHER****

          Thank you very much for submitting your manuscript “[PAPER TITLE]” for consideration at PLOS Biology. Your manuscript has been evaluated by the PLOS Biology editorial staff, by an Academic Editor with relevant expertise, and by several independent reviewers.

          ****OR (if previous OPEN REJECT)****

          Thank you very much for submitting a revised version of your manuscript "[PAPER TITLE]" for consideration at PLOS Biology. This revised version of your manuscript has been evaluated by the PLOS Biology editorial staff, an Academic Editor and reviewers. 

          ****

          In light of the reviews, we will not be able to accept the current version of the manuscript, but we would welcome resubmission of a much-revised version that takes into account the reviewers' comments. We cannot make any decision about publication until we have seen the revised manuscript and your response to the reviewers' comments. Your revised manuscript is also likely to be sent for further evaluation by the reviewers. 

          Your revisions should address the specific points made by each reviewer. Please also submit a cover letter and a point-by-point response to all of the reviewers' comments that indicates the changes you have made to the manuscript. You should also cite any additional relevant literature that has been published since the original submission and mention any additional citations in your response. 

          Please note that as a condition of publication PLOS’ data policy requires that you make available all data used to draw conclusions in papers published in PLOS journals. If you have not already done so, you must include any data used in your manuscript either in appropriate repositories, within the body of the manuscript, or as supporting information (NB this includes any numerical values that were used to generate graphs, histograms etc.). For an example see here: http://www.plosbiology.org/article/info%3Adoi%2F10.1371%2Fjournal.pbio.1001908#s5.

          Upon resubmission, the editors will assess the advance your revised manuscript represents over work published prior to its resubmission in reaching a decision regarding further consideration. The editors also will assess the revisions you have made and decide whether to consult further with an Academic Editor. If the editors and Academic Editor feel that the revised manuscript remains appropriate for the journal and that the revisions are sufficient to warrant further consideration, we generally will send the manuscript for re-review. We aim to consult the same Academic Editor and reviewers for revised manuscripts but may consult others if needed.

          We expect to receive your revised manuscript within two months. Please email us (plosbiology@plos.org) to discuss this if you have any questions or concerns, or would like to request an extension. 

          At this stage, your manuscript remains formally under active consideration at our journal. Please note that unless we receive the revised manuscript within this timeframe, your submission may be closed and the manuscript would no longer be ‘under consideration’ at PLOS Biology. We will of course be in touch before this action is taken. Please rest assured that this is merely an administrative step - you may still submit your revised submission after your file is closed, but will need to do so as a new submission, referencing the previous tracking number.

          Please notify us by email if you do not wish to revise your manuscript for PLOS Biology and instead wish to pursue publication elsewhere, so that we may end consideration of the manuscript at PLOS Biology.

          If you do still intend to submit a revised version of your manuscript, please log in at http://www.aperta.tech.  On the ‘Your Manuscripts’ page, click the title of your manuscript to access and edit your submission.

          Before you revise your manuscript, we ask that you please review the following PLOS policy and formatting requirements checklist PDF: https://drive.google.com/file/d/0B_7IflO1bmDTYlZBdmJCT1FUWG8/view?usp=sharing. It’s helpful for you to take a look through this at this stage, and to align your revision with our requirements; should your paper be eventually accepted, this will save everyone time at the acceptance stage. 

          Thank you again for your submission to our journal. We hope that our editorial process has been constructive thus far, and we welcome your feedback at any time. Please don't hesitate to contact us if you have any questions or comments. 
          Sincerely,

          [EDITOR NAME]
          [EDITOR TITLE]
          PLOS Biology

          ------------------------------------------------------------------------

          Reviewer Notes:
          [REVIEWER COMMENTS]
          TEXT
        subject = 'Your [JOURNAL NAME] submission'
        to_field = '[AUTHOR EMAIL]'
        template = LetterTemplate.where(template_decision: 'major_revision', text: text, journal: journal).first_or_create!
        template.update_attributes(to: to_field, subject: subject, letter: letter)

        text   = 'RA Minor Revision'
        letter = <<-TEXT.strip_heredoc
          ** CHOOSE BETWEEN NUMBERED PARAGRAPHS BELOW
          **REMOVE THIS TEXT BEFORE SENDING**

          Dear Dr. [LAST NAME],

          [1] 
          Thank you very much for submitting your manuscript "[PAPER TITLE]" for review by PLOS Biology. As with all papers reviewed by the journal, yours was seen by the PLOS editorial staff as well as by an Academic Editor with relevant expertise. In this case, your article was also evaluated by independent reviewers. The reviewers appreciated the attention to an important topic. Based on the reviews, we will probably accept this manuscript for publication, providing that you are willing and able to modify the manuscript according to the review recommendations.

          [2] 
          Thank you for submitting your revised manuscript entitled "[PAPER TITLE]" for publication in PLOS Biology. I have now obtained advice from the original reviewers and have discussed their comments with the Academic Editor. 

          *******
          DELETE AS APPROPRIATE – TWO LARGE SECTIONS TO CHOOSE BETWEEN

          EITHER [3]:
          Based on the reviews, we will probably accept this manuscript for publication, assuming that you are willing and able to modify the manuscript to address the remaining concerns raised by the reviewers.

          ***Insert Editorial Requirements and INCLUDE DATA REQUIREMENTS AS NECESSARY***

          We expect to receive your revised manuscript within two weeks. Your revisions should address the specific points made by each reviewer.

          In addition to the remaining revisions and before we will be able to formally accept your manuscript and consider it "in press", we also need to ensure that your article conforms to our guidelines. A member of our team will be in touch shortly with a set of requests regarding the manuscript files. As we can’t proceed until these requirements are met, your swift response will help prevent delays to publication.
          OR [4]:
          We’re delighted to let you know that we’re now editorially satisfied with your manuscript, however before we can formally accept your manuscript and consider it "in press", we also need to ensure that your article conforms to our guidelines. A member of our team will be in touch shortly with a set of requests regarding the manuscript files. As we can’t proceed until these requirements are met, your swift response will help prevent delays to publication. 
          ******* 
          Upon acceptance of your article, your final files will be copyedited and typeset into the final PDF. While you will have an opportunity to review these files as proofs, PLOS will only permit corrections to spelling or significant scientific errors. Therefore, please take this final revision time to assess and make any remaining major changes to your manuscript.
          To submit your revision, please log in at http://www.aperta.tech.  Click the title of your manuscript from the Your Manuscripts page to access and edit your submission. Your revised submission must include a cover letter, and a Response to Reviewers that provides a detailed response to the reviewers' comments (if applicable) and indication of any changes that you have made to the manuscript. 
          Please do not hesitate to contact me should you have any questions.

          Sincerely,

          [EDITOR NAME]
          [EDITOR TITLE]
          PLOS Biology

          ------------------------------------------------------------------------

          DATA POLICY:
          You may be aware of the PLOS Data Policy, which requires that all data be made available without restriction: http://journals.plos.org/plosbiology/s/data-availability. For more information, please also see this editorial: http://dx.doi.org/10.1371/journal.pbio.1001797

          Note that we do not require all raw data. Rather, we ask that all individual quantitative observations that underlie the data summarized in the figures and results of your paper be made available in one of the following forms:

          1) Supplementary files (e.g., excel). Please ensure that all data files are uploaded as 'Supporting Information' and are invariably referred to (in the manuscript, figure legends, and the Description field when uploading your files) using the following format verbatim: S1 Data, S2 Data, etc. Multiple panels of a single or even several figures can be included as multiple sheets in one excel file that is saved using exactly the following convention: S1_Data.xlsx (using an underscore).

          2) Deposition in a publicly available repository. Please also provide the accession code or a reviewer link so that we may view your data before publication. 

          Regardless of the method selected, please ensure that you provide the individual numerical values that underlie the summary data displayed in the following figure panels: (e.g. Figs. ....), as they are essential for readers to assess your analysis and to reproduce it. Please also ensure that figure legends in your manuscript include information on where the underlying data can be found.

          Please ensure that your Data Availability card in the submission system accurately describes where your data can be found.

          ------------------------------------------------------------------------

          Reviewer remarks:

          [REVIEWER COMMENTS]
          TEXT
        subject = 'Your [JOURNAL NAME] submission'
        to_field = '[AUTHOR EMAIL]'
        template = LetterTemplate.where(template_decision: 'minor_revision', text: text, journal: journal).first_or_create!
        template.update_attributes(to: to_field, subject: subject, letter: letter)

        text   = 'RA Accept'
        letter = <<-TEXT.strip_heredoc
          Dear Dr. [LAST NAME],

          I am pleased to inform you that your manuscript, [PAPER TITLE], has been deemed suitable for publication in [JOURNAL NAME]. Congratulations!

          Your manuscript will now be passed on to our Production staff, who will check your files for correct formatting and completeness. During this process, you may be contacted to make necessary alterations to your manuscript, though not all manuscripts require this.

          If you or your institution will be preparing press materials for this manuscript, you must inform our press team in advance. Your manuscript will remain under a strict press embargo until the publication date and time.

          Please contact me if you have any other questions or concerns. Thank you for submitting your work to [JOURNAL NAME].

          With kind regards,

          [YOUR NAME]
          [JOURNAL NAME]
          TEXT
        subject = 'Your [JOURNAL NAME] submission'
        to_field = '[AUTHOR EMAIL]'
        template = LetterTemplate.where(template_decision: 'accept', text: text, journal: journal).first_or_create!
        template.update_attributes(to: to_field, subject: subject, letter: letter)
      end
    end
  end
end
