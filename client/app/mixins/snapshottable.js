import Ember from 'ember';

export default Ember.Mixin.create({
  snapshots: DS.hasMany('snapshot', {async: true, inverse: 'source' })
});
