import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {
  model() {
    return this.store.createRecord('discussion-topic', {
      paperId: this.modelFor('paper').get('id').toString(),
      title: ''
    });
  },

  actions: {
    cancel(model) {
      model.deleteRecord();
      this.transitionTo(this.get('topicsIndexPath'));
    },

    save(model) {
      model.save().then(()=> {
        this.transitionTo(this.get('topicsShowPath'), model);
      });
    }
  }
});
