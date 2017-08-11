import Ember from 'ember';
import { task as concurrencyTask, timeout } from 'ember-concurrency';

export default Ember.Mixin.create({

  pusher: Ember.inject.service('pusher'),
  flash: Ember.inject.service('flash'),

  pusherNotConnected: Ember.computed.alias('pusher.isDisconnected'),
  // this alias works, but is not observable
  pusherConnectionState: Ember.computed.alias('pusher.connection.connection.state'),

  handlePusherConnectionStatusChange() {
    if (this.get('pusherConnectionState') === 'connecting') {
      this.get('handlePusherConnecting').perform();
    } else {
      this.cleanupPusherConnecting();
    }
    if (this.get('pusherNotConnected')) {
      this.updatePusherConnectionMessage();
    }
  },

  cleanupPusherConnecting() {
    // remove the connecting message on connecting -> connected transition
    let messages = this.get('flash').get('systemLevelMessages');
    let connectionMessage = messages.findBy('text', this.pusherFailureMessage('connecting'));
    this.get('flash').removeSystemLevelMessage(connectionMessage);
  },

  handlePusherConnecting: concurrencyTask(function*() {
    if (!Ember.isTesting) {
      // Pusher tries to connect for 10s. Handle the resulting connection state.
      yield timeout(10000);
    }
    this.handlePusherConnectionStatusChange();
  }).drop(),

  updatePusherConnectionMessage() {
    let message = this.pusherFailureMessage(this.get('pusherConnectionState'));
    let messages = this.get('flash').get('systemLevelMessages').filterBy('text', message);
    if (!messages.length) {
      this.get('flash').displaySystemLevelMessage('error', message);
    }
  },

  pusherFailureMessage(failureState) {
    switch (failureState) {
    case 'unavailable':
      return `Aperta is currently having trouble maintaining a live connection with your browser.
          This could impact updates to the interface, and we recommend you 
          <a href="#" onclick="window.location.reload(false)"> reload this page</a>
          to attempt to re-establish the connection`;
    case 'failed':
      return `Aperta is having trouble establishing a live connection with your browser
            due to lack of browser support for required software.
            <a href="http://browsehappy.com/">Please update your browser to the current version</a>`;
    case 'disconnected':
      return `Aperta\'s live connection with your browser has been dropped. 
          This could impact updates to the interface,
          and we recommend you <a href="#" onclick="window.location.reload(false)">reload this page</a> 
          to attempt to re-establish the connection.`;
    case 'connecting':
      return `Aperta is attempting to acquire a live connection. Please wait until connection is established.`;
    default:
      return false;
    }
  }
});
