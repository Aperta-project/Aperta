import DS from 'ember-data';

export default DS.Model.extend({
  task: DS.belongsTo('task'),
  user: DS.belongsTo('user')
});