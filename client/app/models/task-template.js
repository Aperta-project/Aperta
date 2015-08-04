import DS from 'ember-data';

export default DS.Model.extend({
  journalTaskType: DS.belongsTo('journal-task-type'),
  phaseTemplate: DS.belongsTo('phase-template'),

  template: DS.attr(),
  title: DS.attr('string')
});
