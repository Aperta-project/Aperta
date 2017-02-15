namespace :card_seed do
  desc "Seed cards for each type of Answerable"
  task seed: [
    'card_seed:author',
    'card_seed:authors_task',
    'card_seed:competing_interests_task',
    'card_seed:cover_letter_task',
    'card_seed:data_availability_task',
    'card_seed:early_posting_task',
    'card_seed:ethics_task',
    'card_seed:figure_task',
    'card_seed:financial_disclosure_task',
    'card_seed:front_matter_reviewer_report_task',
    'card_seed:funder',
    'card_seed:group_author',
    'card_seed:plos_billing_task',
    'card_seed:plos_bio_final_tech_check_task',
    'card_seed:plos_bio_initial_tech_check_task',
    'card_seed:plos_bio_revision_tech_check_task',
    'card_seed:production_metadata_task',
    'card_seed:publishing_related_questions_task',
    'card_seed:register_decision_task',
    'card_seed:reporting_guidelines_task',
    'card_seed:reviewer_recommendation',
    'card_seed:reviewer_report_task',
    'card_seed:taxon_task'
  ]
end
