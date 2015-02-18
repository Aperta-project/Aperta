// import DS   from 'ember-data';
import Task from 'tahi/models/task';

// BillingCardTask = Task.extend({
//   qualifiedType: "BillingCard::BillingCardTask"
// })
// export default BillingCardTask;

export default DS.Model.extend({
  journalId: DS.attr('number'),
  paperId: DS.attr('number'),

  pfa_funding_statement: DS.attr('string'),
  pfa_question_1: DS.attr('string'),
  pfa_question_1a: DS.attr('string'),
  pfa_question_1b: DS.attr('string'),
  pfa_question_2: DS.attr('string'),
  pfa_question_2a: DS.attr('string'),
  pfa_question_2b: DS.attr('string'),
  pfa_question_3: DS.attr('string'),
  pfa_question_3a: DS.attr('string'),
  pfa_question_4: DS.attr('string'),
  pfa_question_4a: DS.attr('string'),
  pfa_amount_to_pay: DS.attr('string'),
  pfa_supporting_docs: DS.attr('string'),
  pfa_additional_comments: DS.attr('string'),
  first_name: DS.attr('string'),
  last_name: DS.attr('string'),
  title: DS.attr('string'),
  department: DS.attr('string'),
  affiliation1: DS.attr('string'),
  affiliation2: DS.attr('string'),
  phone_number: DS.attr('string'),
  email_address: DS.attr('string'),
  address1: DS.attr('string'),
  address2: DS.attr('string'),
  city: DS.attr('string'),
  state: DS.attr('string'),
  postal_code: DS.attr('string'),
  country: DS.attr('string')
});
