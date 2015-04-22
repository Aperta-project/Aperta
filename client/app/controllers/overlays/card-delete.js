import Ember from 'ember';

export default Ember.Controller.extend({
  overlayClass: 'overlay--fullscreen paper-submit-overlay',

  actions: {
    closeAction() {
      this.set('model', null);
      this.send('closeOverlay');
    },

    removeTask() {
      this.get('model').destroyRecord().then(() => {
        this.send('closeOverlay');
      });
    }
  }
});
