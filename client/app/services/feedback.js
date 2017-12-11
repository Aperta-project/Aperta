import Ember from 'ember';

export default Ember.Service.extend({
  restless: Ember.inject.service('restless'),

  sendFeedback(referrer, remarks, screenshots) {
    let paperId = this.get('paper.id');
    return this.get('restless').post('/api/feedback', {
      feedback: {referrer, remarks, paper_id: paperId, screenshots }
    });
  },

  setContext(paper) {
    this.set('paper', paper);
  },

  clearContext() {
    this.set('paper', null);
  }
});
