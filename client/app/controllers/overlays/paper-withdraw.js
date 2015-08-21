import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Controller.extend({
  overlayClass: 'overlay--fullscreen overlay--grey',

  actions: {
    withdraw() {
      var reason = this.get('model.withdrawalReason');
      RESTless.putUpdate(this.get('model'), '/withdraw', {'reason': reason}).then(()=> {
        this.send('closeOverlay');
      });
    }
  }
});
