import DS from 'ember-data';
import Task from 'tahi/models/task';

export default Task.extend({
  invitationTemplate: DS.attr(),
  inviteeRole: DS.attr('string'),
  relationshipsToSerialize: ['academicEditors', 'participants'],
  academicEditors: DS.hasMany('user')
});
