import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper'),
  user: DS.belongsTo('user')
});
