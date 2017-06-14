import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {
  can: Ember.inject.service(),
  currentUser: Ember.inject.service(),

  beforeModel(transition){
    this.get('can').can('start_discussion', this.paperModel()).then( (value)=> {
      if (!value){
        return this.handleUnauthorizedRequest(transition);
      }
    });
  },

  model() {
    return this.store.createRecord('discussion-topic', {
      paperId: this.paperModel().get('id').toString(),
      title: ''
    });
  },

  activate() {
    this.send('updatePopoutRoute', 'new');
  },

  setupAtMentionables(controller) {
    const discussionRouteName = `paper.${this.get('subRouteName')}.discussions`;
    const discussionModel =  this.modelFor(discussionRouteName);
    controller.set('atMentionableStaffUsers', discussionModel.atMentionableStaffUsers);
  },

  // TODO: Remove this when we have routeable components.
  // Controllers are currently singletons and this property sticks around
  setupController(controller, model) {
    this.setupAtMentionables(controller);
    controller.set('replyText', '');
    controller.set('validationErrors', {});
    controller.set('participants', [this.get('currentUser')]);
    return this._super(controller, model);
  },

  actions: {
    cancel(topic) {
      topic.deleteRecord();
      this.transitionTo(this.get('topicsIndexPath'));
    }
  }
});
