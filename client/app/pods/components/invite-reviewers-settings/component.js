import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {
  restless: Ember.inject.service(),
  store: Ember.inject.service(),

  classNames: ['invite-reviewer-settings'],

  actions: {
    close() {
      this.get('close')();
    },
    saveSettings () {
      // save meee
    }
  }
});
