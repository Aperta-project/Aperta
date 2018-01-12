import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: false }),
  tasks: DS.hasMany('task', {
    polymorphic: true,
    async: true
  }),

  name: DS.attr('string'),
  position: DS.attr('number'),

  noTasks: Ember.computed.empty('tasks.[]')
});
