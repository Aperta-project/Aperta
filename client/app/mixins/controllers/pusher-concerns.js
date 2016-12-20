import Ember from 'ember';

export default Ember.Mixin.create({

  pusher: Ember.inject.service('pusher'),
  flash: Ember.inject.service('flash'),

  debounceTimer: null,
  pusherConnectionState: 'unknown',
  pusherConnecting: false,

  handlePusherConnectionSuccess() {
    Ember.run.cancel(this.get('debounceTimer')); //
    this.set('debounceTimer', null);
    this.set('pusherConnecting', false);
  },

  handlePusherConnecting() {
    this.set('pusherConnecting', true);
    if (!this.get('debounceTimer')) {
      let debounce = Ember.run.debounce(this, function() {
        let message = this._pusherFailureMessage('unavailable');
        this.get('flash').displaySystemLevelMessage('error', message);
      }, 10000);
      this.set('debounceTimer', debounce);
    }
  },

  handlePusherConnectionFailure() {
    Ember.run.scheduleOnce('afterRender', this, () => {
      let message = this._pusherFailureMessage(this.get('pusherConnectionState'));
      this.get('flash').displaySystemLevelMessage('error', message);
    });
  },

  _pusherFailureMessage(failureState) {
    switch (failureState) {
    case 'unavailable':
      return `Aperta is currently having trouble maintaining a live connection with your browser.
            This could impact updates to the interface, and we recommend you 
            <a href="#" onclick="window.location.reload(false)"> reload this page</a>
            to attempt to re-establish the connection`;
    case 'failed':
      return `Aperta is having trouble establishing a live connection with your browser, 
            due to lack of browser support for required software.
            You may experience difficulty with live updates to the interface, 
            and we recommend downloading the most recent version of your browser
            or trying <a href="https://www.google.com/chrome/" target="_blank">Google Chrome.</a>`;
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
