import Ember from 'ember';

export default Ember.Route.extend({
  // model() {
  //   return this.store.find('paper-discussion', {
  //     paper_id: this.modelFor('paper').get('id')
  //   });
  // },

  actions: {
    hideDiscussions() {
      this.transitionTo('paper.workflow');
    }
  }
});
