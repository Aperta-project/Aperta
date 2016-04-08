import Ember from 'ember';
import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';

const { attr, belongsTo } = DS;

export const contributionIdents = [
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
  'group-author--contributions--formal-analysis',
];


export default NestedQuestionOwner.extend({
  paper: belongsTo('paper', { async: false }),

  contactFirstName: attr('string'),
  contactLastName: attr('string'),
  contactMiddleName: attr('string'),
  contactEmail: attr('string'),

  name: attr('string'),
  initial: attr('string'),

  position: attr('number'),

  displayName: Ember.computed.alias('name'),

  validations: {
    'name': ['presence'],
    'contactFirstName': ['presence'],
    'contactLastName': ['presence'],
    'contactEmail': ['presence', 'email'],
   'government': [{
      type: 'presence',
      message: 'A selection must be made',
      validation() {
        const author = this.get('object');
        const answer = author
              .answerForQuestion('group-author--government-employee')
              .get('value');

        return answer === true || answer === false;
      }
    }],
    'contributions': [{
      type: 'presence',
      message: 'One must be selected',
      validation() {
        const author = this.get('object');

        return _.some(contributionIdents, (ident) => {
          return author.answerForQuestion(ident).get('value');
        });
      }
    }]
  }
});
