import Ember from 'ember';
import { task as concurrencyTask, timeout } from 'ember-concurrency';

export default Ember.Mixin.create({

  pusher: Ember.inject.service('pusher'),
  flash: Ember.inject.service('flash'),

  pusherIsDisconnected: Ember.computed.alias('pusher.isDisconnected'),
  pusherConnectionState: Ember.computed.alias('pusher.connection.connection.state'),

  handlePusherConnectionStatusChange: concurrencyTask(function*() {
    yield timeout(10000);

    this.clearPusherConnectionMessages();
    if (this.get('pusherIsDisconnected')) {
      this.updatePusherConnectionMessage();
    }
  }).drop(),

  updatePusherConnectionMessage() {
    let message = this.pusherFailureMessages[this.get('pusherConnectionState')];
    if (message) {
      this.get('flash').displaySystemLevelMessage('error', message);
    }
  },

  clearPusherConnectionMessages() {
    ['unavailable', 'failed', 'disconnected', 'connecting'].forEach((key) => {
      let systemFlash = this.get('flash').get('systemLevelMessages');
      let existingMessages = systemFlash.filterBy('text', this.pusherFailureMessages[key]);
      systemFlash.removeObjects(existingMessages);
    });
  },

  pusherFailureMessages: {
    unavailable: `Aperta is currently having trouble maintaining a live connection with your browser.
            This could impact updates to the interface, and we recommend you 
            <a href="#" onclick="window.location.reload(false)"> reload this page</a>
            to attempt to re-establish the connection`,
    failed: `Aperta is having trouble establishing a live connection with your browser
              due to lack of browser support for required software.
              <a href="http://browsehappy.com/">Please update your browser to the current version</a>`,
    disconnected: `Aperta\'s live connection with your browser has been dropped. 
            This could impact updates to the interface,
            and we recommend you <a href="#" onclick="window.location.reload(false)">reload this page</a> 
            to attempt to re-establish the connection.`,
    connecting: `Aperta is attempting to acquire a live connection. Please wait until connection is established.`
  }
});
