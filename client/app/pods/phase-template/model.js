import Ember from 'ember';
import DS from 'ember-data';
import DependentRelationships from 'tahi/mixins/dependent-relationships';

export default DS.Model.extend(DependentRelationships, {
  manuscriptManagerTemplate: DS.belongsTo('manuscript-manager-template', {
    async: false
  }),
  taskTemplates: DS.hasMany('task-template', { async: false }),

  name: DS.attr('string'),
  position: DS.attr('number'),

  noTasks: Ember.computed.empty('taskTemplates')
});
