import Ember from 'ember';

export default Ember.Controller.extend({
  restless: Ember.inject.service('restless'),
  overlayClass: 'overlay--fullscreen overlay--grey',

  actions: {
    withdraw() {
      var reason = this.get('model.withdrawalReason');
      this.get('restless').putUpdate(this.get('model'), '/withdraw', {'reason': reason})
      .then(()=> {
        this.send('closeOverlay');
      });
    }
  }
});
