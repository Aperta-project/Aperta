import Ember from 'ember';
import { task as concurrencyTask, timeout } from 'ember-concurrency';

export default Ember.Mixin.create({

  pusher: Ember.inject.service('pusher'),
  flash: Ember.inject.service('flash'),

  pusherIsDisconnected: Ember.computed.alias('pusher.isDisconnected'),
  pusherConnectionState: Ember.computed.alias('pusher.connection.connection.state'),

  handlePusherConnectionStatusChange: concurrencyTask(function*() {
    let state = null;
    switch (this.get('pusherConnectionState')) {
    case 'failed':
      state = 'failed';
      break;
    case 'unavailable':
    case 'disconnected':
      state = 'unavailable';
    }

    if (state) {
      this.updatePusherConnectionMessage(state);
    }
  }).drop(),

  updatePusherConnectionMessage(key) {
    let message = this.pusherFailureMessages[key];
    let messages = this.get('flash').get('systemLevelMessages').filterBy('text', message);
    if (!messages.length) {
      this.get('flash').displaySystemLevelMessage('error', message);
    }
  },

  pusherFailureMessages: {
    unavailable: `Aperta is currently having trouble maintaining a live connection with your browser.
            This could impact updates to the interface, and we recommend you 
            <a href="#" onclick="window.location.reload(false)"> reload this page</a>
            to attempt to re-establish the connection`,
    failed: `Aperta is having trouble establishing a live connection with your browser
              due to lack of browser support for required software.
              <a href="http://browsehappy.com/">Please update your browser to the current version</a>`
  }
});
