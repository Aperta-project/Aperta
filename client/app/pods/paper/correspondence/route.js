import AuthorizedRoute from 'tahi/pods/authorized/route';
import Ember from 'ember';

export default AuthorizedRoute.extend({
  restless: Ember.inject.service('restless'),

  model() {
    let paper = this.modelFor('paper');
    let paperId = paper.get('id');
    this.get('restless').get(`/api/papers/${paperId}/correspondence`).then((data)=> {
      this.store.pushPayload(data);
    });
    return paper.get('correspondences');
  },

  setupController(controller) {
    this._super(...arguments);
    controller.set('paper', this.modelFor('paper'));
  }
});
