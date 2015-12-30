import Ember from 'ember';
import DS from 'ember-data';
import Task from 'tahi/models/task';

const { attr } = DS;
const { computed } = Ember;

export default Task.extend({
  decisionLetters: attr('string'),
  paperDecision: attr('string'),
  paperDecisionLetter: attr('string'),

  acceptLetterTemplate: computed('decisionLetters', function() {
    return JSON.parse(this.get('decisionLetters')).accept;
  }),

  rejectLetterTemplate: computed('decisionLetters', function() {
    return JSON.parse(this.get('decisionLetters')).reject;
  }),

  majorRevisionLetterTemplate: computed('decisionLetters', function() {
    return JSON.parse(this.get('decisionLetters')).major_revision;
  }),

  minorRevisionLetterTemplate: computed('decisionLetters', function() {
    return JSON.parse(this.get('decisionLetters')).minor_revision;
  })
});
