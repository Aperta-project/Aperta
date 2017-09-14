import Ember from 'ember';

export default Ember.Component.extend({
  task: Ember.computed.reads('owner')
});
