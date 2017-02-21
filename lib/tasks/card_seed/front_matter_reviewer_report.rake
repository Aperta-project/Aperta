namespace 'card_seed' do
  task 'front_matter_reviewer_report': :environment do
    content = []

    content << {
      ident: 'front_matter_reviewer_report--decision_term',
      value_type: 'text',
      text: 'Please provide your publication recommendation:'
    }

    content << {
      ident: "front_matter_reviewer_report--competing_interests",
      value_type: "text",
      text: "Do you have any potential or perceived competing interests that may influence your review?"
    }

    content << {
      ident: "front_matter_reviewer_report--suitable",
      value_type: "boolean",
      text: "Is this manuscript suitable in principle for the magazine section of <em>PLOS Biology</em>?",
      children: [
        {
          ident: "front_matter_reviewer_report--suitable--comment",
          value_type: "text",
          text: "Suitable Comment"
        }
      ]
    }

    content << {
      ident: "front_matter_reviewer_report--includes_unpublished_data",
      value_type: "boolean",
      text: "If previously unpublished data are included to support the conclusions, please note in the box below whether:",
      children: [
        {
          ident: "front_matter_reviewer_report--includes_unpublished_data--explanation",
          value_type: "text",
          text: "Includes Published Data Explanation"
        }
      ]
    }

    content << {
      ident: "front_matter_reviewer_report--additional_comments",
      value_type: "text",
      text: "(Optional) Please offer any additional confidential comments to the editor"
    }

    content << {
      ident: "front_matter_reviewer_report--identity",
      value_type: "text",
      text: "(Optional) If you'd like your identity to be revealed to the authors, please include your name here."
    }

    CardSeeder.seed_card('FrontMatterReviewerReport', content)
  end
end
