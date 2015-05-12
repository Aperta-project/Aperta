import DS from 'ember-data';

export default DS.Model.extend({
  user: DS.belongsTo('user'),
  task: DS.belongsTo('task', { polymorphic: true })
});
