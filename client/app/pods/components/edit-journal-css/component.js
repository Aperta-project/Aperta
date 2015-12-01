import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {
  css: null,

  actions: {
    close() { this.attrs.close(); },
    save() {
      this.attrs.save(this.get('type'), this.get('css'));
      this.attrs.close();
    }
  }
});
