import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  queueTitle: DS.attr('string'),
  task: DS.belongsTo('task', { async: true }),
  primary: DS.belongsTo('invitation', { inverse: 'inviteQueue', async: true }),
  decision: DS.belongsTo('decision'),
  mainQueue: DS.attr('boolean'),
  invitations: DS.hasMany('invitation', { async: true })
});
