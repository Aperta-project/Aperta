import DS from 'ember-data';

export default DS.Model.extend({
  journalTaskType: DS.belongsTo('journalTaskType'),
  phaseTemplate: DS.belongsTo('phaseTemplate'),

  template: DS.attr(),
  title: DS.attr('string')
});
