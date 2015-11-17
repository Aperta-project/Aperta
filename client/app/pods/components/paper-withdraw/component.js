import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {
  restless: Ember.inject.service('restless'),

  actions: {
    withdraw() {
      const model = this.get('model');
      const url   = '/withdraw';
      const data  = {'reason': this.get('model.withdrawalReason')};

      this.get('restless').putUpdate(model, url, data).then(()=> {
        this.attrs.close();
      });
    },

    close() {
      this.attrs.close();
    }
  }
});
