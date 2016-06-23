import Ember from 'ember';

export default Ember.Route.extend({
  model: function(params) {
    return this.store.findRecord('manuscript-manager-template', params.manuscript_manager_template_id);
  },

  actions: {
    willTransition(transition) {
      if (this.controller.get('pendingChanges')) {
        alert("There are changes in this template please save first");
        transition.abort();
      }
    }
  }
});
