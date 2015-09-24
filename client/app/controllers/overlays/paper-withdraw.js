import Ember from 'ember';

export default Ember.Controller.extend({
  restless: Ember.inject.service('restless'),
  overlayClass: 'overlay--fullscreen overlay--grey',

  actions: {
    withdraw() {
      const model = this.get('model');
      const url   = '/withdraw';
      const data  = {'reason': this.get('model.withdrawalReason')};

      this.get('restless').putUpdate(model, url, data).then(()=> {
        this.send('closeOverlay');
      });
    }
  }
});
