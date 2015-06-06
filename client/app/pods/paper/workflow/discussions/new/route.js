import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.createRecord('discussion-topic', {
      paperId: this.modelFor('paper').get('id').toString(),
      title: ''
    });
  },

  actions: {
    cancel(model) {
      model.deleteRecord();
      this.transitionTo('paper.workflow.discussions.index');
    },

    save(model) {
      model.save().then(()=> {
        this.transitionTo('paper.workflow.discussions.show', model);
      });
    }
  }
});
