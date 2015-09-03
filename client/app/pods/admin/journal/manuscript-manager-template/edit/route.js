import Ember from 'ember';

export default Ember.Route.extend({
  model: function(params) {
    return this.store.find('manuscriptManagerTemplate', params.manuscript_manager_template_id);
  },

  actions: {
    saveChanges: function() {
      return this.controller.send('saveTemplate', this.get('attemptingTransition'));
    }
  }
});
