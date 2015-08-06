import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  manuscriptManagerTemplate: DS.belongsTo('manuscript-manager-template', {
    async: false
  }),
  taskTemplates: DS.hasMany('task-template', { async: false }),

  name: DS.attr('string'),
  position: DS.attr('number'),

  noTasks: Ember.computed.empty('taskTemplates')
});
