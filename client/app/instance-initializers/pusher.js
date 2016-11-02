import Ember from 'ember';
import ENV from '../config/environment';

export function initialize(instance) {
  const pusherOptions = ENV.APP.PUSHER_OPTS;
  Ember.assert(
    'Define PUSHER_OPTS in your config',
    typeof pusherOptions !== 'undefined'
  );


  let bugsnagService = instance.lookup('service:bugsnag');

  const pusher = new window.Pusher(pusherOptions.key, pusherOptions.connection);

  /*
    Tell somebody about Pusher error states
    =========================================
    Reference: https://pusher.com/docs/client_api_guide/client_connect
  */

  // The Pusher connection was previously connected and has now intentionally
  // been closed.
  pusher.connection.bind('disconnected', function(){
    bugsnagService.notifyException(
      'PusherDisconnected',
      'Pusher.js has disconnected'
    );
  });

  // Pusher is not supported by the browser. This implies that WebSockets are
  // not natively available and an HTTP-based transport could not be found.
  pusher.connection.bind('failed', function(){
    bugsnagService.notifyException(
      'PusherNotSupported',
      'Pusher.js is not supported by the browser.'
    );
  });

  // The connection is temporarily unavailable. In most cases this means that
  // there is no internet connection. It could also mean that Pusher is down, or
  //  some intermediary is blocking the connection. In this state, Pusher will
  // automatically retry the connection every ten seconds. connecting_in events
  // will still be triggered.
  pusher.connection.bind('unavailable', function(){
    bugsnagService.notifyException(
      'PusherUnavailable',
      'Pusher.js is unavailable.'
    );
  });

  const pusherController = instance.container.lookup('pusher:main');
  pusherController.didCreatePusher(pusher);

  instance.registry.injection('controller', 'pusher', 'pusher:main');
  instance.registry.injection('route',      'pusher', 'pusher:main');
  instance.registry.injection('service:notifications', 'pusher', 'pusher:main');
}

export default {
  name: 'pusher',
  initialize: initialize
};
