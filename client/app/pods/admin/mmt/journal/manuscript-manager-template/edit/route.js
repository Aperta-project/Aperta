import Ember from 'ember';

export default Ember.Route.extend({
  actions: {
    willTransition(transition) {
      if (this.controller.get('pendingChanges')) {
        alert("There are changes in this template please save first");
        transition.abort();
      }
    }
  }
});
