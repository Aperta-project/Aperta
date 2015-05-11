import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper'),
  task: DS.belongsTo('task', { polymorphic: true }),

  completed: DS.attr('boolean'),
  createdAt: DS.attr('string'),
  position: DS.attr('number'),
  taskType: DS.attr('string'),
  title: DS.attr('string')
});
