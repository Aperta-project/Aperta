import Ember from 'ember';

export default Ember.Component.extend({
  restless: Ember.inject.service('restless'),
  withdrawn: Ember.computed.equal('paper.publishingState', 'withdrawn'),
  actions: {
    reactivate: function() {
      this.get('restless').putUpdate(this.get('paper'), '/reactivate').then(()=> {
      });
    }
  }
});
