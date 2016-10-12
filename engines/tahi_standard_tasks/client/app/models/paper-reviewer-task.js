import DS from 'ember-data';
import Task from 'tahi/models/task';
import InviteQueueable from 'tahi/mixins/invite-queueable';

export default Task.extend(InviteQueueable, {
  invitationTemplate: DS.attr(),
  inviteeRole: DS.attr('string'),
  relationshipsToSerialize: ['reviewers', 'participants'],
  reviewers: DS.hasMany('user')
});
