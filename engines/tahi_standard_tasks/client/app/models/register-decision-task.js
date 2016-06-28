import Ember from 'ember';
import DS from 'ember-data';
import Task from 'tahi/models/task';

const { attr } = DS;
const { computed } = Ember;

export default Task.extend({
  decisionLetters: attr('string'),
  paperDecision: attr('string'),
  paperDecisionLetter: attr('string'),

  rejectLetterTemplates: computed('decisionLetters', function() {
    return JSON.parse(this.get('decisionLetters')).reject;
  }),

  majorRevisionLetterTemplates: computed('decisionLetters', function() {
    return JSON.parse(this.get('decisionLetters')).major_revision;
  }),

  minorRevisionLetterTemplates: computed('decisionLetters', function() {
    return JSON.parse(this.get('decisionLetters')).minor_revision;
  }),

  acceptLetterTemplates: computed('decisionLetters', function() {
    return JSON.parse(this.get('decisionLetters')).accept;
  })
});
