import Ember from 'ember';
import EventStream from 'tahi/services/event-stream';

export default {
  name: 'eventStream',
  after: 'currentUser',
  initialize: function(container, application) {
    let store = container.lookup('store:main');
    let es = !container.lookup('user:current') || Ember.testing ? Ember.Object.extend({
      play()  { return null; },
      pause() { return null; }
    }) : EventStream;

    container.register('eventstream:main', es.extend({
      store: store
    }), {
      singleton: true
    });

    application.inject('route', 'eventStream', 'eventstream:main');
  }
};
