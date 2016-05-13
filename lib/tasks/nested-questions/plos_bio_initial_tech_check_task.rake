namespace 'nested-questions:seed' do
  task 'plos-bio-initial-tech-check-task': :environment do
    questions = []
    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--ethics_statement",
      value_type: "boolean",
      text: "Make sure the ethics statement looks complete. If the authors have responded Yes to any question, but have not provided approval information, please request this from them.",
      position: 1
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--data_availability_confidential",
      value_type: "boolean",
      text: "In the Data Availability card, if the answer to Q1 is 'No' or if the answer to Q2 is 'Data are from the XXX study whose authors may be contacted at XXX' or 'Data are available from the XXX Institutional Data Access/ Ethics Committee for researchers who meet the criteria for access to confidential data', start a 'MetaData' discussion and ping the handling editor.",
      position: 2
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--data_availability_blank",
      value_type: "boolean",
      text: "In the Data Availability card, if the authors have not selected one of the reasons listed in Q2 and pasted it into the text box, please request that they complete this section.",
      position: 3
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--data_availability_dryad",
      value_type: "boolean",
      text: "In the Data Availability card, if the authors have mentioned data submitted to Dryad, check that the author has provided the Dryad reviewer URL and if not, request it from them. ",
      position: 4
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--authors_match",
      value_type: "boolean",
      text: "Compare the author list between the manuscript file and the Authors card. If the author list does not match, request the authors to update whichever section is missing information. Ignore omissions of middle initials.",
      position: 5
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--author_emails",
      value_type: "boolean",
      text: "If we don't have unique email addresses for all authors, send it back.",
      position: 6
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--author_removed",
      value_type: "boolean",
      text: "If the author list has changed between initial and full submission, pass it through if an author was added and flag it to the editor/initiate our COPE process if an author was removed.",
      position: 7
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--competing_interests",
      value_type: "boolean",
      text: "Check that the Competing Interest card has been filled out correctly. If the authors have selected Yes and not provided an explanation, send it back.",
      position: 8
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--financial_disclosure",
      value_type: "boolean",
      text: "Check that the Financial Disclosure card has been filled out correctly. Ensure the authors have provided a description of the roles of the funder, if they responded Yes to our standard statement.",
      position: 9
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--tobacco",
      value_type: "boolean",
      text: " If the Financial Disclosure Statement includes any companies from the Tobacco Industry, start a 'MetaData' discussion and ping the handling editor. See <a href='http://en.wikipedia.org/wiki/Category:Tobacco_companies_of_the_United_States'>this list</a>.",
      position: 10
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--collection",
      value_type: "boolean",
      text: "If the authors mention submitting their paper to a collection in the cover letter or Additional Information card, alert Jenni Horsley by pinging her through the discussion of the ITC card.",
      position: 11
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--figures_viewable",
      value_type: "boolean",
      text: "Make sure you can view and download all files uploaded to your Figures card. Check against figure citations in the manuscript to ensure there are no missing figures.",
      position: 12
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--embedded_captions",
      value_type: "boolean",
      text: "If main figures or supporting information captions are only available in the file itself (and not in the manuscript), request that the author remove the captions from the file and instead place them in the manuscript file.",
      position: 13
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--captions_missing",
      value_type: "boolean",
      text: "If main figures or supporting information captions are missing entirely, ask the author to provide them in the manuscript file.",
      position: 14
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--figures_missing",
      value_type: "boolean",
      text: "If any files or figures are cited in the manuscript but not included in the Figures or Supporting Information cards, ask the author to provide the missing information. (Search Fig, Table, Text, Movie and check that they are in the file inventory).",
      position: 15
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name,
      ident: "plos_bio_initial_tech_check--open_reject",
      value_type: "boolean",
      text: "For any resubmissions after an Open Reject decision, ensure the authors have uploaded A 'Response to Reviewer's document. If this information is provided in the cover letter or another part of the submission, ask the authors to upload it as a new file and if this information is not present, request the file from author.",
      position: 16
    }

    NestedQuestion.where(
      owner_type: PlosBioTechCheck::InitialTechCheckTask.name
    ).update_all_exactly!(questions)
  end
end
