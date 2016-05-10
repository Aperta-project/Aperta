import Ember from 'ember';

export default Ember.Service.extend({
  restless: Ember.inject.service('restless'),

  sendFeedback(referrer, remarks, screenshots) {
    return this.get('restless').post('/api/feedback', {
      feedback: {referrer, remarks, screenshots}
    });
  }
});
