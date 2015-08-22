import Ember from 'ember';
import ENV from 'tahi/config/environment';
import { Controller } from 'ember-pusher/controller';

export function initialize(registry, application) {
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
    ENV.APP.PUSHER_OPTS.connection = Ember.merge(ENV.APP.PUSHER_OPTS.connection, {
      wsHost: window.eventStreamConfig.host,
      wsPort: window.eventStreamConfig.port,
      wssPort: window.eventStreamConfig.port
    });
  }

  Ember.assert('Pusher library is required', typeof window.Pusher !== 'undefined');
  application.register('pusher:main', Controller);
}

export default {
  name: 'pusher',
  initialize: initialize
};
