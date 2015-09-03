import Ember from 'ember';

export default Ember.Component.extend({
  withdrawn: Ember.computed.equal('paper.publishingState', 'withdrawn')
});
