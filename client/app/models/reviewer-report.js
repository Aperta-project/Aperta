import DS from 'ember-data';

export default DS.Model.extend({
  decision: DS.belongsTo('decision'),
  task: DS.belongsTo('task'),
  user: DS.belongsTo('user')
});