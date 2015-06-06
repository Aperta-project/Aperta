import Ember from 'ember';

export default Ember.Route.extend({
  actions: {
    hideDiscussions() {
      this.transitionTo('paper.workflow');
    }
  }
});
