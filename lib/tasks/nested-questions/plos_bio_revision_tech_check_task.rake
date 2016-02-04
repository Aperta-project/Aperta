namespace 'nested-questions:seed' do
  task 'plos-bio-revision-tech-check-task': :environment do
    questions = []
    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::RevisionTechCheckTask.name,
      ident: "plos_bio_revision_tech_check--open_rejects",
      value_type: "boolean",
      text: "Check Section Headings of all new submissions (including Open Rejects). Should broadly follow: Title, Authors, Affiliations, Abstract, Introduction, Results, Discussion, Materials and Methods, References, Acknowledgements, and Figure Legends.",
      position: 1
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::RevisionTechCheckTask.name,
      ident: "plos_bio_revision_tech_check--human_subjects",
      value_type: "boolean",
      text: "Check the ethics statement - does it mention Human Participants? If so, flag this with the editor in the discussion below.",
      position: 2
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::RevisionTechCheckTask.name,
      ident: "plos_bio_revision_tech_check--ethics_needed",
      value_type: "boolean",
      text: "Check if there are any obvious ethical flags (mentions of animal/human work in the title/abstract), check that there's an ethics statement. If not, ask the authors about this.",
      position: 3
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::RevisionTechCheckTask.name,
      ident: "plos_bio_revision_tech_check--data_available",
      value_type: "boolean",
      text: "Is the data available? If not, or it's only available by contacting an author or the institution, make a note in the discussion below.",
      position: 4
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::RevisionTechCheckTask.name,
      ident: "plos_bio_revision_tech_check--supporting_information",
      value_type: "boolean",
      text: "If author indicates the data is available in Supporting Information, check to make sure there are Supporting Information files in the submission (don't need to check for specifics at this stage).",
      position: 5
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::RevisionTechCheckTask.name,
      ident: "plos_bio_revision_tech_check--dryad_url",
      value_type: "boolean",
      text: "If the author has mentioned Dryad in their Data statement, check that they've included the Dryad reviewer URL. If not, make a note in the discussion below.",
      position: 6
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::RevisionTechCheckTask.name,
      ident: "plos_bio_revision_tech_check--financial_disclosure",
      value_type: "boolean",
      text: "If Financial Disclosure Statement is not complete (they've written N/A or something similar), message author.",
      position: 7
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::RevisionTechCheckTask.name,
      ident: "plos_bio_revision_tech_check--tobacco",
      value_type: "boolean",
      text: "If the Financial Disclosure Statement includes any companies from the Tobacco Industry, make a note in the discussion below.",
      position: 8
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::RevisionTechCheckTask.name,
      ident: "plos_bio_revision_tech_check--figures_legible",
      value_type: "boolean",
      text: "If any figures are completely illegible, contact the author.",
      position: 9
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::RevisionTechCheckTask.name,
      ident: "plos_bio_revision_tech_check--cited",
      value_type: "boolean",
      text: "If any files or figures are cited but not included in the submission, message the author.",
      position: 10
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::RevisionTechCheckTask.name,
      ident: "plos_bio_revision_tech_check--cover_letter",
      value_type: "boolean",
      text: "Have the authors asked any questions in the cover letter? If yes, contact the editor/journal team.",
      position: 11
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::RevisionTechCheckTask.name,
      ident: "plos_bio_revision_tech_check--billing_inquiries",
      value_type: "boolean",
      text: "Have the authors mentioned any billing information in the cover letter? If yes, contact the editor/journal team.",
      position: 12
    }

    questions << {
      owner_id: nil,
      owner_type: PlosBioTechCheck::RevisionTechCheckTask.name,
      ident: "plos_bio_revision_tech_check--ethics_statement",
      value_type: "boolean",
      text: "If an Ethics Statement is present, make a note in the discussion below.",
      position: 13
    }

    NestedQuestion.where(
      owner_type: PlosBioTechCheck::RevisionTechCheckTask.name
    ).update_all_exactly!(questions)
  end
end
