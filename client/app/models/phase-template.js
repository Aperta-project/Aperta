import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  manuscriptManagerTemplate: DS.belongsTo('manuscriptManagerTemplate'),
  taskTemplates: DS.hasMany('taskTemplate'),

  name: DS.attr('string'),
  position: DS.attr('number'),

  noTasks: Ember.computed.empty('taskTemplates')
});
