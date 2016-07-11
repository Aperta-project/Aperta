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

  rejectLetterTemplates: computed.filterBy('letterTemplates',
      'templateDecision', 'reject'),

  majorRevisionLetterTemplates: computed.filterBy('letterTemplates',
     'templateDecision', 'major_revision'),

  minorRevisionLetterTemplates: computed.filterBy('letterTemplates',
      'templateDecision', 'minor_revision'),

  acceptLetterTemplates: computed.filterBy('letterTemplates',
      'templateDecision', 'accept')
});
