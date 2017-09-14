import DS from 'ember-data';
import Task from 'tahi/models/task';

export default Task.extend({
  componentName: 'custom-card-task',
  yieldComponentName: 'paper-reviewer-task',
  invitationTemplate: DS.attr(),
  inviteeRole: DS.attr('string'),
  relationshipsToSerialize: ['reviewers', 'participants'],
  reviewers: DS.hasMany('user'),
  cardVersion: DS.belongsTo('card-version')
});
