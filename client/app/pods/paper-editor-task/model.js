import DS from 'ember-data';
import Task from 'tahi/pods/task/model';

export default Task.extend({
  invitationTemplate: DS.attr(),
  inviteeRole: DS.attr('string'),
  relationshipsToSerialize: ['academicEditors', 'participants'],
  academicEditors: DS.hasMany('user')
});
