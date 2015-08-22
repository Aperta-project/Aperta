import Ember from 'ember';
import ENV from '../config/environment';

export function initialize(instance) {
  var pusherOptions = ENV.APP.PUSHER_OPTS;
  Ember.assert('Define PUSHER_OPTS in your config', typeof pusherOptions !== 'undefined');

  var pusher = new window.Pusher(pusherOptions.key, pusherOptions.connection);
  var pusherController = instance.container.lookup('pusher:main');

  pusherController.didCreatePusher(pusher);

  instance.registry.injection('controller', 'pusher', 'pusher:main');
  instance.registry.injection('route',      'pusher', 'pusher:main');
}

export default {
  name: 'pusher',
  initialize: initialize
};
