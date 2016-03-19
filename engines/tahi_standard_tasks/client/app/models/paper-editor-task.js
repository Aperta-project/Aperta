import Ember from 'ember';
import DS from 'ember-data';
import Task from 'tahi/models/task';

const { computed } = Ember;

export default Task.extend({
  academicEditors: DS.belongsTo('user'),
  relationshipsToSerialize: ['academicEditors', 'participants'],
  inviteeRole: DS.attr('string'),
  invitations: DS.hasMany('invitation', { async: false }),
  invitationTemplate: DS.attr()
});
