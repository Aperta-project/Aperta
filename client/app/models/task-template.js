import DS from 'ember-data';

export default DS.Model.extend({
  journalTaskType: DS.belongsTo('journal-task-type', { async: false }),
  phaseTemplate: DS.belongsTo('phase-template', { async: false }),

  template: DS.attr(),
  title: DS.attr('string')
});
