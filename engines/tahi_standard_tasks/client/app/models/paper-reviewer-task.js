import DS from 'ember-data';
import Task from 'tahi/models/task';

export default Task.extend({
  reviewers: DS.hasMany('user'),
  relationshipsToSerialize: ['reviewers', 'participants'],
  inviteQueues: DS.hasMany('inviteQueue'),
  inviteeRole: DS.attr('string'),
  invitationTemplate: DS.attr()
});
