import Ember from 'ember';
import DS from 'ember-data';

const { computed, isEmpty } = Ember;

export default Ember.Component.extend({
  promise: null,

  promiseProxy: computed('promise', function() {
    if (isEmpty(this.get('promise.then'))) { return null; }
    return DS.PromiseObject.create({promise: this.get('promise')});
  }),

  isFulfilled: computed.reads('promiseProxy.isFulfilled')
});
