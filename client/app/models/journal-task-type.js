import DS from 'ember-data';

export default DS.Model.extend({
  journal: DS.belongsTo('journal', { async: false }),
  kind: DS.attr('string'),
  oldRole: DS.attr('string'),
  title: DS.attr('string')
});
