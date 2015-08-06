import DS from 'ember-data';

export default DS.Model.extend({
  user: DS.belongsTo('user', { async: false }),
  paper: DS.belongsTo('paper', { async: false }),
  role: DS.attr('string'),
  createdAt: DS.attr('date')
});
