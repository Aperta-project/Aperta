import Ember from 'ember';

// Facilitates display of a warning overlay when navigating away from a dirty editor.
// Used in conjuction with client/app/mixins/components/dirty-editor-ember.js
export default Ember.Mixin.create({
  setupController(controller, model) {
    this._super(controller, model);
    controller.set('dirtyEditorConfig', this.get('dirtyEditorConfig'));
  },

  actions: {
    willTransition(transition) {
      let model = this.currentModel;
      let props = this.get('dirtyEditorConfig.properties');
      let dirtyAndRelevant = props.any((item) => model.changedAttributes()[item]);
      let hasDirty = !!(model.get('hasDirtyAttributes') && dirtyAndRelevant);

      if (!hasDirty) {
        return true;
      }

      this.set('previousTransition', transition);
      transition.abort();
      this.set('controller.showDirtyOverlay', true);
    },

    retryStoppedTransition() {
      this.set('controller.showDirtyOverlay', false);
      this.get('previousTransition').retry();
    }
  }
});
