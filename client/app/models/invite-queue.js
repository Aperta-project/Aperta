import DS from 'ember-data';

export default DS.Model.extend({
  queueTitle: DS.attr('string'),
  task: DS.belongsTo('invite-queueable', { polymorphic: true, inverse: 'inviteQueues'}),
  primary: DS.belongsTo('invitation'),
  decision: DS.belongsTo('decision'),
  mainQueue: DS.attr('boolean'),
  invitations: DS.hasMany('invitation', {inverse: 'inviteQueue'})
});
