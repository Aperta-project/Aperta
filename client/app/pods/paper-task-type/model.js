import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: false }),
  kind: DS.attr('string'),
  title: DS.attr('string'),
  roleHint: DS.attr('string'),
  systemGenerated: DS.attr('boolean')
});

