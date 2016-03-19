import Ember from 'ember';
import DS from 'ember-data';
import Task from 'tahi/models/task';

const { computed } = Ember;

export default Task.extend({
  editors: DS.belongsTo('user'),
  relationshipsToSerialize: ['editors', 'participants'],
  inviteeRole: DS.attr('string'),
  invitations: DS.hasMany('invitation', { async: false }),
  invitationTemplate: DS.attr()
});
