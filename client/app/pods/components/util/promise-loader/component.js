import Ember from 'ember';
import DS from 'ember-data';

const { computed, RSVP } = Ember;

export default Ember.Component.extend({
  promise: null,

  promiseProxy: computed('promise', function() {
    return DS.PromiseObject.create({
      promise: RSVP.cast(this.get('promise'))
    });
  }),

  isFulfilled: computed.reads('promiseProxy.isFulfilled')
});
