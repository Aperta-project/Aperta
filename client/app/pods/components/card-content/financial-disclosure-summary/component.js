import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';

let computedFromAnswer = function(ident) {
  return Ember.computed('answers.@each.value', 'repetition', function() {
    return this.answerFor(ident);
  });
};

const Funder = Ember.Object.extend({
  answers: null,
  repetition: null,

  name: computedFromAnswer('funder--name'),
  grantNumber: computedFromAnswer('funder--grant_number'),
  website: computedFromAnswer('funder--website'),
  additionalComments: computedFromAnswer('funder--additional_comments'),

  fundingStatement: Ember.computed('answers', 'repetition', function() {
    return this.answerFor('funder--had_influence--role_description')
      || 'The funder had no role in study design, data collection and analysis, decision to publish, or preparation of the manuscript';
  }),

  onlyHasAdditionalComments: Ember.computed('additionalComments', 'name', 'website', 'grantNumber', function() {
    let name = this.get('name');
    let grantNumber = this.get('grantNumber');
    let website = this.get('website');
    let additionalComments = this.get('additionalComments');
    return !!(additionalComments && !name && !grantNumber && !website);
  }),

  formattedWebsite: Ember.computed('website', function() {
    let website = this.get('website');

    if(Ember.isEmpty(website)) { return null; }

    if (/^https?:\/\//.test(website)) {
      return website;
    } else {
      return 'http://' + website;
    }
  }),

  formattedName: Ember.computed('name', function() {
    let name = this.get('name');

    if(Ember.isEmpty(name)) {
      return '[funder name]';
    } else {
      return name;
    }
  }),

  answerFor(ident) {
    let answers = this.get('answers');
    let repetition = this.get('repetition');

    let answer = answers.filterBy('cardContent.ident', ident).findBy('repetition', repetition);
    if(answer) {
      return answer.get('value');
    } else {
      return null;
    }
  },
});

export default Ember.Component.extend({
  classNames: ['card-content-financial-disclosure-summary'],
  store: Ember.inject.service(),

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    repetition: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired,
    preview: PropTypes.bool
  },

  answers: Ember.computed('owner', 'owner.answers.@each.{value,isDeleted}', function() {
    let answers = this.get('owner').get('answers') || [];
    return answers.rejectBy('isDeleted');
  }),

  funders: Ember.computed('owner', 'owner.repetitions.@each.isDeleted', 'answers.@each.value', function() {
    let owner = this.get('owner');
    let answers = this.get('answers');
    let funderRepetitions = owner.get('repetitions').rejectBy('isDeleted');
    return funderRepetitions.map((repetition) => Funder.create({ answers, repetition }));
  })
});
