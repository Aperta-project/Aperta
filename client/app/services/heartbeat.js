import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Object.extend({
  interval: 90 * 1000,
  intervalId: null,
  resource: null,

  init() {
    if (!this.get('resource')) {
      throw new Error("need to specify resource");
    }
  },

  start() {
    this.heartbeat();
    let heartbeatWrapper = ()=> { return this.heartbeat(); };
    return this.set('intervalId', setInterval(heartbeatWrapper, this.get('interval')));
  },

  stop() {
    if (this.get('intervalId')) {
      clearInterval(this.get('intervalId'));
      this.set('intervalId', null);
    }
  },

  heartbeat() {
    return RESTless.putModel(this.get('resource'), "/heartbeat");
  }
});
