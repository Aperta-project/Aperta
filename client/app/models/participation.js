import DS from 'ember-data';

export default DS.Model.extend({
  user: DS.belongsTo('user', { async: true }),
  task: DS.belongsTo('task', {
    polymorphic: true,
    async: true
  })
});
