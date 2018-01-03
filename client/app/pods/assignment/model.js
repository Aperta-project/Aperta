import DS from 'ember-data';

export default DS.Model.extend({
  user: DS.belongsTo('user', { async: false }),
  paper: DS.belongsTo('paper', { async: false }),
  role: DS.belongsTo('role', { async: false }),
  createdAt: DS.attr('date')
});
