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
    Note: if pusher.connection starts in a bad state it will NOT emit
    any events. It will just start in a bad state. Events are only emitted
    if pusher.connection transitions from one known state to the next.

    Reference: https://pusher.com/docs/client_api_guide/client_connect
  */

  // Pusher is not supported by the browser. This implies that WebSockets are
  // not natively available and an HTTP-based transport could not be found.
  // This is not fired as an event, but set as the connection's state.
  if(Ember.isEqual(pusher.connection.state, "failed")){
    bugsnagService.notifyException(
      'PusherNotSupported',
      'Pusher.js is not supported by the browser'
    );
  };

  // The connection is unavailable. When the server is unavailable
  // on application load the pusher.connection starts out in the unavailable
  // state rather than transitioning to the unavailable state, so we must
  // check it first.
  if(Ember.isEqual(pusher.connection.state, "unavailable")){
    bugsnagService.notifyException(
      'PusherUnavailable',
      'Pusher.js service unavailable on app load'
    );
  };

  // The Pusher connection was previously connected and has now intentionally
  // been closed.
  pusher.connection.bind('disconnected', function(){
    bugsnagService.notifyException(
      'PusherDisconnected',
      'Pusher.js has disconnected'
    );
  });

  // The connection has become unavailable. This implies that the
  // pusher.connection was in another state first. If the pusherjs server
  // is unavailable when the application loads then this will not be triggered.
  pusher.connection.bind('unavailable', function(){
    bugsnagService.notifyException(
      'PusherUnavailable',
      'Pusher.js service became unavailable during app use'
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
