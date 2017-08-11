import Ember from 'ember';
import { task as concurrencyTask, timeout } from 'ember-concurrency';

export default Ember.Mixin.create({

  pusher: Ember.inject.service('pusher'),
  flash: Ember.inject.service('flash'),

  pusherConnectionState: 'unknown',

  handlePusherConnectionStatusChange(){
    this.set('pusherConnectionState', this.pusher.connection.connection.state);

    if (this.pusher.connection.connection.state === 'connecting') {
      this.get('handlePusherConnecting').perform();
    } else {
      this.cleanupPusherConnecting();
    }
    if (this.pusher.get('isDisconnected')) {
      this.handlePusherConnectionFailure();
    }
  },
  
  cleanupPusherConnecting() {
    // remove the connecting message on connecting -> connected transition
    let messages = this.get('flash').get('systemLevelMessages');
    let connectionMessage = messages.findBy('text', this._pusherFailureMessage('connecting'));
    this.get('flash').removeSystemLevelMessage(connectionMessage);
  },
  
  handlePusherConnecting: concurrencyTask(function*() {
    if(!Ember.isTesting){
      // Pusher tries to connect for 10s. Handle the resulting connection state.
      yield timeout(10000);
    }
    this.handlePusherConnectionStatusChange();
  }).drop(),

  handlePusherConnectionFailure() {
    let message = this._pusherFailureMessage(this.get('pusherConnectionState'));
    this.get('flash').displaySystemLevelMessage('error', message);
  },

  _pusherFailureMessage(failureState) {
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
