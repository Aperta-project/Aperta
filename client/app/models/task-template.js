import DS from 'ember-data';
import Ember from 'ember';

export default DS.Model.extend({
  journalTaskType: DS.belongsTo('journal-task-type', { async: false }),
  phaseTemplate: DS.belongsTo('phase-template', { async: false }),
  position: DS.attr('number'),
  template: DS.attr(),
  title: DS.attr('string'),
  type: 'adHocTemplate',
  kind: Ember.computed.alias('journalTaskType.kind')
});
