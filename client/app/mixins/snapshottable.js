import Ember from 'ember';
import DS from 'ember-data';

export default Ember.Mixin.create({
  snapshots: DS.hasMany('snapshot', {async: true, inverse: 'source' })
});
