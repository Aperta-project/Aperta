import Ember from 'ember';
import { task as concurrencyTask, timeout } from 'ember-concurrency';

export default Ember.Mixin.create({

  pusher: Ember.inject.service('pusher'),
  flash: Ember.inject.service('flash'),

  pusherIsConnected: Ember.computed.not('pusher.isDisconnected'),
  pusherConnectionState: Ember.computed.alias('pusher.connection.connection.state'),

  handlePusherConnectionStatusChange: concurrencyTask(function*() {
    yield timeout(10000);
    if (this.get('pusherIsConnected')) {
      this._clearConnectionMessages();
    } else {
      this._updateConnectionMessage();
    }
  }).drop(),

  _updateConnectionMessage() {
    this._clearConnectionMessages();
    let message = this.pusherFailureMessages[this.get('pusherConnectionState')];
    this.get('flash').displaySystemLevelMessage('error', message);
  },

  _clearConnectionMessages() {
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
