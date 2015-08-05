import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: false }),
  user: DS.belongsTo('user', { async: false })
});
