import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    var id = params.email_id;
    return this.store.findRecord('letter-template', id, {reload: true});
  },
  actions: {
    willTransition: function () {
      let model = this.currentModel;
      if (model.get('hasDirtyAttributes')) {
        model.rollbackAttributes();
      }
    }
  }
});
