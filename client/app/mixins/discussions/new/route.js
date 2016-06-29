import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {
  can: Ember.inject.service('can'),

  beforeModel(transition){
    this.get('can').can('start_discussion', this.modelFor('paper')).then( (value)=> {
      if (!value){
        return this.handleUnauthorizedRequest(transition);
      }
    })
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
    let discussionRouteName = `paper.${this.get('subRouteName')}.discussions`;
    const discussionModel = this.modelFor(discussionRouteName);
    controller.set('atMentionableStaffUsers', discussionModel.atMentionableStaffUsers);
    controller.set('replyText', '');
    return this._super(controller, model);
  },

  createReply(replyText, topic) {
    topic.get('discussionReplies').createRecord({
      discussionTopic: topic,
      replier: this.get('currentUser'),
      body: replyText
    }).save();
  },


  actions: {
    cancel(topic) {
      topic.deleteRecord();
      this.transitionTo(this.get('topicsIndexPath'));
    },

    save(topic, replyText) {
      topic.save().then(()=> {
        if(!Ember.isEmpty(replyText)) {
          this.createReply(replyText, topic);
        }

        this.transitionTo(this.get('topicsShowPath'), topic);
      });
    }
  }
});
