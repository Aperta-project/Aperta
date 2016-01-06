import Ember from 'ember';
import DS from 'ember-data';

const { PromiseObject } = DS;

export default Ember.Component.extend({
  promise: null,
  promiseProxy: Ember.computed('promise', function() {
    if (Ember.isEmpty(this.get('promise.then'))) { return null; }
    return PromiseObject.create({promise: this.get('promise')});
  }),

  isFulfilled: Ember.computed.reads('promiseProxy.isFulfilled')

});
