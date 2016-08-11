import DS from 'ember-data';
import Task from 'tahi/models/task';

export default Task.extend({
  reviewers: DS.hasMany('user'),
  relationshipsToSerialize: ['reviewers', 'participants'],
  inviteeRole: DS.attr('string'),
  invitationTemplate: DS.attr()
});
