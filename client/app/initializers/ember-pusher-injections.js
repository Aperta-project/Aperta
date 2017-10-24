import Ember from 'ember';
import ENV from 'tahi/config/environment';

export function initialize() {

  ENV.APP.PUSHER_OPTS = {
    key: window.eventStreamConfig.key,
    connection: {
      authEndpoint: window.eventStreamConfig.auth_endpoint_path,
      encrypted: false,
      disableStats: true,
      enabledTransports: ['ws']
    }
  };
  if (window.eventStreamConfig.host) {
    let connection = ENV.APP.PUSHER_OPTS.connection;
    let websocket  = {
      wsHost: window.eventStreamConfig.host,
      wsPort: window.eventStreamConfig.port,
      wssPort: window.eventStreamConfig.port
    };
    ENV.APP.PUSHER_OPTS.connection = Ember.merge(connection, websocket);
  }
}

export default {
  name: 'ember-pusher-options',
  initialize: initialize
};
