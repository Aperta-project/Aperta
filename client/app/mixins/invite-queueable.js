import Ember from 'ember';
import DS from 'ember-data';

export default Ember.Mixin.create({
  inviteQueues: DS.hasMany('inviteQueue'),
});
