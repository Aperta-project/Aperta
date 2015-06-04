import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.createRecord('discussion-topic', {
      paper: this.modelFor('paper'),
      title: ''
    });
  },

  actions: {
    cancel(model) {
      model.deleteRecord();
      this.transitionTo('paper.workflow.discussions.index');
    },

    save(model) {
      this.transitionTo('paper.workflow.discussions.show', model);
      // model.save().then(()=> {
      //   this.transitionTo('paper.workflow.discussions.show', model);
      // });
    }
  }
});
