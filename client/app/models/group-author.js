import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';

const { attr, belongsTo } = DS;

export default NestedQuestionOwner.extend({
  paper: belongsTo('paper', { async: false }),
  task: belongsTo('authors-task'),

  contactFirstName: attr('string'),
  contactLastName: attr('string'),
  contactMiddleName: attr('string'),
  contactEmail: attr('string'),

  name: attr('string'),
  initial: attr('string'),

  position: attr('number')
});
