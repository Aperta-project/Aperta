import Ember from 'ember';
import DS from 'ember-data';
import Task from 'tahi/models/task';

const { attr } = DS;
const { computed } = Ember;

export default Task.extend({
  decisionLetters: attr('string'),
  paperDecision: attr('string'),
  paperDecisionLetter: attr('string'),
  letterTemplates: DS.hasMany('letter-template', { async: false }),

  rejectLetterTemplates: computed('letterTemplates', function() {
    return this.get('letterTemplates');
  }),

  majorRevisionLetterTemplates: computed('letterTemplates', function() {
    return this.get('letterTemplates');
  }),

  minorRevisionLetterTemplates: computed('letterTemplates', function() {
    return this.get('letterTemplates');
  }),

  acceptLetterTemplates: computed('letterTemplates', function() {
    return this.get('letterTemplates');
  })
});
