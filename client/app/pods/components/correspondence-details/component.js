import Ember from 'ember';

export default Ember.Component.extend({
  routing: Ember.inject.service('-routing'),
  actions: {
    editCorrespondence() {
      this.get('routing').transitionTo('paper.correspondence.edit', [this.get('message.id')]);
    }
  }
});