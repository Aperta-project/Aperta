import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {
  flash: Ember.inject.service(),
  restless: Ember.inject.service('restless'),

  hasWithdrawalReason: Ember.computed.notEmpty('model.withdrawalReason'),

  actions: {
    withdraw() {
      const model = this.get('model');
      const url   = '/withdraw';
      const data  = {'reason': this.get('model.withdrawalReason')};

      if(this.get('hasWithdrawalReason')) {
        this.get('restless').putUpdate(model, url, data).then(()=> {
          this.attrs.close();
        });
      }
      else {
        this.get('flash').displayMessage('error', 'Enter withdrawal reason');
      }
    },

    close() {
      this.attrs.close();
    }
  }
});
