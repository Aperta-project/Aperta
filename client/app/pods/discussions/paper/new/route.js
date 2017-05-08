import Ember from 'ember';

export default Ember.Route.extend({
  can: Ember.inject.service(),
  currentUser: Ember.inject.service(),

  beforeModel(transition){
    this.get('can').can('start_discussion', this.modelFor('discussions.paper')).then( (value)=> {
      if (!value){
        return this.handleUnauthorizedRequest(transition);
      }
    });
  },

  model() {
    return this.store.createRecord('discussion-topic', {
      paperId: this.modelFor('discussions.paper').get('id').toString(),
      title: ''
    });
  },

  // TODO: Remove this when we have routeable components.
  // Controllers are currently singletons and this property sticks around
  setupController(controller, model) {
    const paperRouteName = 'discussions.paper';
    const paperModel = this.modelFor(paperRouteName);
    paperModel.atMentionableStaffUsers().then( (users) => {
      controller.set('atMentionableStaffUsers', users);
    });
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
