import DS from 'ember-data';

export default DS.Model.extend({
  journal: DS.belongsTo('admin-journal', { async: false }),
  kind: DS.attr('string'),
  title: DS.attr('string'),
  systemGenerated: DS.attr('boolean')
});
