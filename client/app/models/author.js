import Ember from 'ember';
import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';
import { contributionIdents } from 'tahi/authors-task-validations';

const { attr, belongsTo } = DS;

export default NestedQuestionOwner.extend({
  paper: belongsTo('paper', { async: false }),
  task: belongsTo('authors-task'),

  authorInitial: attr('string'),
  firstName: attr('string'),
  middleInitial: attr('string'),
  lastName: attr('string'),
  email: attr('string'),
  title: attr('string'),
  department: attr('string'),

  currentAddressStreet: attr('string'),
  currentAddressStreet2: attr('string'),
  currentAddressCity: attr('string'),
  currentAddressState: attr('string'),
  currentAddressCountry: attr('string'),
  currentAddressPostal: attr('string'),

  affiliation: attr('string'),
  ringgoldId: attr('string'),

  secondaryAffiliation: attr('string'),
  secondaryRinggoldId: attr('string'),

  position: attr('number'),
  corresponding: attr('boolean'),
  deceased: attr('boolean'),

  validations: {
    'firstName': ['presence'],
    'lastName': ['presence'],
    'authorInitial': ['presence'],
    'email': ['presence', 'email'],
    'affiliation': ['presence'],
    'government': [{
      type: 'presence',
      message: 'A selection must be made',
      validation() {
        const author = this.get('object');
        const answer = author.answerForQuestion('author--government-employee')
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
  },

  displayName: Ember.computed('firstName', 'middleInitial', 'lastName', function() {
    return [
      this.get('firstName'),
      this.get('middleInitial'),
      this.get('lastName')
    ].compact().join(' ');
  })
});
