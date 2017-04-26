import DS from 'ember-data';

export default DS.Model.extend({
  role: DS.belongsTo('role', { async: true }),
  card: DS.belongsTo('card', { async: true }),
  action: DS.attr('string')
});
