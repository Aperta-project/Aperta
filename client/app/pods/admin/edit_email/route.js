import Ember from 'ember';

export default Ember.Route.extend({
  showDirtyOverlay: false,
  model(params) {
    return this.store.findRecord('letter-template', params.email_id, {reload: true});
  },

  actions: {
    willTransition(transition) {
      let model = this.currentModel;
      let hasDirtyBody = !!(model.get('hasDirtyAttributes') && model.changedAttributes()['body']);
      if(!hasDirtyBody) {
        return true;
      }

      this.set('previousTransition', transition);
      transition.abort();
      this.set('controller.showDirtyOverlay', true);
    },

    allowStoppedTransition() {
      this.set('controller.showDirtyOverlay', false);
      let transition = this.get('previousTransition');
      transition.retry();
    }
  }
});
