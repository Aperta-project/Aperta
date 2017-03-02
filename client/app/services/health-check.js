import Ember from 'ember';
import { task, timeout } from 'ember-concurrency';

export default Ember.Service.extend({
  intervalInMilliseconds: 30000,
  status: 'healthy',
  failureMessage: "<span>ALERT - STOP YOUR WORK</span><br>" +
    "The Aperta system is having a problem. If you are currently entering text, copy your work and exit Aperta. " +
    "We will fix the problem as soon as possible. " +
    "Check back later - if this message is gone, it is safe to work in Aperta again. Sorry for the interruption.",

  flash: Ember.inject.service('flash'),

  start() {
    if (Ember.testing) { return; }
    this.get('poll').perform();
  },

  poll: task(function* () {
    while(this.get('status') === 'healthy') {
      yield this.checkHealthEndpoint();
      yield timeout(this.get('intervalInMilliseconds'));
    }
  }),

  checkHealthEndpoint() {
    return new Ember.RSVP.Promise((resolve, reject) => {
      // this must be wrapped, or Ember will not allow us to test
      $.ajax({
        method: 'GET',
        cache: false,
        url: '/health',
        dataType: 'html'
      }).then(
        resolve,
        (e) => {
          if (e.status === 500) {
            this.displayErrorAndStopPolling();
          }
          reject(e);
        }
      );
    });
  },

  displayErrorAndStopPolling() {
    this.set('status', 'unhealthy');
    this.get('flash').displaySystemLevelMessage('critical-error', this.get('failureMessage'));
  },
});
