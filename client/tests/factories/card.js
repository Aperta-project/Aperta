import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('card', {
  default: {
    name: 'Test Card'
  },

  traits: {
    author: {
      name: 'Author',
      cardContent: [{ ident: 'author--published_as_corresponding_author' }]
    }
  }
});

let cardIdents = {
  'Author': [
    'author--published_as_corresponding_author',
    'author--deceased',
    'author--government-employee',
    'author--contributions--conceptualization',
    'author--contributions--investigation',
    'author--contributions--visualization',
    'author--contributions--methodology',
    'author--contributions--resources',
    'author--contributions--supervision',
    'author--contributions--software',
    'author--contributions--data-curation',
    'author--contributions--project-administration',
    'author--contributions--validation',
    'author--contributions--writing-original-draft',
    'author--contributions--writing-review-and-editing',
    'author--contributions--funding-acquisition',
    'author--contributions--formal-analysis'
  ],
  'FrontMatterReviewerReport': [
    'front_matter_reviewer_report--decision_term',
    'front_matter_reviewer_report--competing_interests',
    'front_matter_reviewer_report--suitable',
    'front_matter_reviewer_report--suitable--comment',
    'front_matter_reviewer_report--includes_unpublished_data',
    'front_matter_reviewer_report--includes_unpublished_data--explanation',
    'front_matter_reviewer_report--additional_comments',
    'front_matter_reviewer_report--identity'
  ],
  'GroupAuthor': [
    'group-author--contributions--conceptualization',
    'group-author--contributions--investigation',
    'group-author--contributions--visualization',
    'group-author--contributions--methodology',
    'group-author--contributions--resources',
    'group-author--contributions--supervision',
    'group-author--contributions--software',
    'group-author--contributions--data-curation',
    'group-author--contributions--project-administration',
    'group-author--contributions--validation',
    'group-author--contributions--writing-original-draft',
    'group-author--contributions--writing-review-and-editing',
    'group-author--contributions--funding-acquisition',
    'group-author--contributions--formal-analysis'
  ],
  'PlosBilling::BillingTask': [
    'plos_billing--first_name',
    'plos_billing--last_name',
    'plos_billing--title',
    'plos_billing--department',
    'plos_billing--phone_number',
    'plos_billing--email',
    'plos_billing--address1',
    'plos_billing--address2',
    'plos_billing--city',
    'plos_billing--state',
    'plos_billing--postal_code',
    'plos_billing--country',
    'plos_billing--affiliation1',
    'plos_billing--affiliation2',
    'plos_billing--payment_method',
    'plos_billing--pfa_question_1',
    'plos_billing--pfa_question_1a',
    'plos_billing--pfa_question_1b',
    'plos_billing--pfa_question_2',
    'plos_billing--pfa_question_2a',
    'plos_billing--pfa_question_2b',
    'plos_billing--pfa_question_3',
    'plos_billing--pfa_question_3a',
    'plos_billing--pfa_question_4',
    'plos_billing--pfa_question_4a',
    'plos_billing--pfa_amount_to_pay',
    'plos_billing--pfa_supporting_docs',
    'plos_billing--pfa_amount_to_pay',
    'plos_billing--pfa_additional_comments',
    'plos_billing--affirm_true_and_complete',
    'plos_billing--agree_to_collections',
    'plos_billing--gpi_country',
    'plos_billing--ringgold_institution'
  ],
  'ReviewerReport': [
    'reviewer_report--decision_term',
    'reviewer_report--competing_interests',
    'reviewer_report--competing_interests--detail',
    'reviewer_report--identity',
    'reviewer_report--comments_for_author',
    'reviewer_report--additional_comments',
    'reviewer_report--suitable_for_another_journal',
    'reviewer_report--suitable_for_another_journal--journal'
  ],
  'TahiStandardTasks::AuthorsTask': [
    'authors--persons_agreed_to_be_named',
    'authors--authors_confirm_icmje_criteria',
    'authors--authors_agree_to_submission'
  ],
  'TahiStandardTasks::EarlyPostingTask': ['early-posting--consent'],
  'TahiStandardTasks::FinancialDisclosureTask': [
    'financial_disclosures--author_received_funding'
  ],
  'TahiStandardTasks::Funder': [
    'funder--had_influence',
    'funder--had_influence--role_description'
  ],
  'TahiStandardTasks::FigureTask': ['figures--complies'],
  'TahiStandardTasks::RegisterDecisionTask': [
    'register_decision_questions--selected-template',
    'register_decision_questions--to-field',
    'register_decision_questions--subject-field'
  ],
  'TahiStandardTasks::ReportingGuidelinesTask': [
    'reporting_guidelines--clinical_trial',
    'reporting_guidelines--systematic_reviews',
    'reporting_guidelines--systematic_reviews--checklist',
    'reporting_guidelines--meta_analyses',
    'reporting_guidelines--meta_analyses--checklist',
    'reporting_guidelines--diagnostic_studies',
    'reporting_guidelines--epidemiological_studies',
    'reporting_guidelines--microarray_studies'
  ]
};

export function createCard(cardName) {
  let content = cardIdents[cardName].map(i =>
    FactoryGuy.make('card-content', { ident: i }));
  return FactoryGuy.make('card', { name: cardName, cardContent: content });
}
