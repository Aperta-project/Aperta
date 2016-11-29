import Ember from 'ember';
import DS from 'ember-data';
import NestedQuestionOwner from 'tahi/models/nested-question-owner';

const { attr, belongsTo } = DS;
const {
  computed,
  computed: { alias }
} = Ember;

export const contributionIdents = [
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
  'author--contributions--formal-analysis',
];

const validations = {
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
};

export default NestedQuestionOwner.extend({
  paper: belongsTo('paper', { async: false }),
  user: belongsTo('user'),

  orcidAccount: alias('user.orcidAccount'),
  orcidIdentifier: alias('user.orcidAccount.identifier'),

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

  init() {
    this._super(...arguments);
    if(window.RailsEnv.orcidConnectEnabled) {
      validations['orcidIdentifier'] = ['presence'];
    }
  },

  validations: validations,

  displayName: computed('firstName', 'middleInitial', 'lastName', function() {
    return [
      this.get('firstName'),
      this.get('middleInitial'),
      this.get('lastName')
    ].compact().join(' ');
  })
});
