import Ember from 'ember';

export default Ember.Mixin.create({
  showDirtyOverlay: false,
  actions: {
    willTransition(transition) {
      let model = this.currentModel;
      let dirtyProps = this.get('dirtyEditorConfig.properties');
      let hasDirty = !!(model.get('hasDirtyAttributes') && dirtyProps.any((item) => model.changedAttributes()[item]));

      if(!hasDirty) {
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
