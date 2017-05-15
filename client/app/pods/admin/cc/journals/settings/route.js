import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    var journalModel = this.modelFor('admin.cc.journals');

    if (journalModel.journals.get('length') === 1) {
      // User has only one journal, so use this one
      // for managing settings.
      return journalModel.journals.get('firstObject');
    } else {
      // Must return `null` (rather than `undefined`)
      // if a specific journal has not been selected.
      // Otherwise, `setupController()` will no-op.
      return journalModel.journal || null;
    }
  }
});
