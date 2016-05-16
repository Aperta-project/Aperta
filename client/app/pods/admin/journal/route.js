import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.findRecord('admin-journal', params.journal_id);
  }
});
