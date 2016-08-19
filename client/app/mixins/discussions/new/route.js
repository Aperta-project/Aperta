import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {
  can: Ember.inject.service('can'),

  beforeModel(transition){
    this.get('can').can('start_discussion', this.modelFor('paper')).then( (value)=> {
      if (!value){
        return this.handleUnauthorizedRequest(transition);
      }
    });
  },

  model() {
    return this.store.createRecord('discussion-topic', {
      paperId: this.modelFor('paper').get('id').toString(),
      title: ''
    });
  },

  // TODO: Remove this when we have routeable components.
  // Controllers are currently singletons and this property sticks around
  setupController(controller, model) {
    const discussionRouteName = `paper.${this.get('subRouteName')}.discussions`;
    const discussionModel = this.modelFor(discussionRouteName);
    controller.set('atMentionableStaffUsers', discussionModel.atMentionableStaffUsers);
    controller.set('replyText', '');
    controller.set('validationErrors', {});
    return this._super(controller, model);
  },

  actions: {
    cancel(topic) {
      topic.deleteRecord();
      this.transitionTo(this.get('topicsIndexPath'));
    }
  }
});
