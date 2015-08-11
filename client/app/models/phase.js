import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: false }),
  tasks: DS.hasMany('task', {
    polymorphic: true,
    async: false
  }),

  name: DS.attr('string'),
  position: DS.attr('number'),
  taskPositions: DS.attr(''),

  noTasks: Ember.computed.empty('tasks.[]'),

});
