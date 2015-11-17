import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {
  actions: {
    removeTask() {
      this.get('model').destroyRecord().then(() => {
        this.attrs.close();
      });
    },

    close() {
      this.attrs.close();
    }
  }
});
