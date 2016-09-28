import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  queueTitle: DS.attr('string'),
  task: DS.belongsTo('task', { async: true }),
  primary: DS.belongsTo('primary', { async: true }),
  invitations: DS.hasMany('invitation', { async: true })
});
