import Ember from 'ember';
import ENV from 'tahi/config/environment';

export default {
  name: 'pusher-override',
  before: 'pusher',
  initialize: function() {
    ENV['APP']['PUSHER_OPTS'] = {
      key: window.eventStreamConfig.key,
      connection: {
        authEndpoint: window.eventStreamConfig.auth_endpoint_path,
        encrypted: false,
        disableStats: true,
        enabledTransports: ['ws']
      }
    };
    if (window.eventStreamConfig.host) {
      return ENV['APP']['PUSHER_OPTS']['connection'] = Ember.merge(ENV['APP']['PUSHER_OPTS']['connection'], {
        wsHost: window.eventStreamConfig.host,
        wsPort: window.eventStreamConfig.port,
        wssPort: window.eventStreamConfig.port
      });
    }
  }
};
