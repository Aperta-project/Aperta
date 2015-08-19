import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Controller.extend({
  overlayClass: 'overlay--fullscreen overlay--green paper-submit-overlay',

  actions: {
    withdraw() {

      RESTless.putUpdate(this.get('model'), '/withdraw').then(()=> {
        this.send('closeOverlay');
      });
    }
  }
});
