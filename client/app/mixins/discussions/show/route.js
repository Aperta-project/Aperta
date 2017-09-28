import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {
  notifications: Ember.inject.service(),
  storage: Ember.inject.service('discussions-storage'),
  channelName: null,
  can: Ember.inject.service('can'),

  model(params) {
    return this.store.findRecord('discussion-topic', params.topic_id);
  },

  redirect(model) {
    var paperId = this.paperModel().get('id');

    if (model.get('paperId') !== paperId) {
      this.transitionTo(this.get('topicsIndexPath'));
    }
  },

  afterModel(topic, transition){
    return this.get('can').can('view', topic).then( (value)=> {
      if (!value){
        return this.handleUnauthorizedRequest(transition);
      }
      this.setModelChannel(topic);
    });
  },

  setModelChannel(model) {
    this.set('modelId', model.get('id'));
    const name = 'private-discussion_topic@' + model.get('id');

    this.set('channelName', name);
    this.get('pusher').wire(this, name, ['created', 'updated']);
  },

  activate() {
    this.send('updatePopoutRoute', 'show');
    this.send('updateDiscussionId', this.modelId);
  },

  deactivate() {
    this.get('pusher').unwire(this, this.channelName);

    this.get('notifications').remove({
      type: 'DiscussionTopic',
      id: this.get('modelId'),
      isParent: true
    });
  },

  setupController(controller, model) {
    let discussionRouteName = this.get('topicsBasePath');
    const discussionModel = this.modelFor(discussionRouteName);
    const mentionableStaffUsers = discussionModel.atMentionableStaffUsers;
    if(typeof mentionableStaffUsers === typeof function(){}) {
      discussionModel.atMentionableStaffUsers()
        .then(promise => promise)
        .then(promises => Ember.RSVP.all(promises).then(res => controller.set('atMentionableStaffUsers', res)));
    } else {
      controller.set('atMentionableStaffUsers', mentionableStaffUsers);
    }
    
    // console.log('atMentionableStaffUsers', discussionModel.atMentionableStaffUsers);
    controller.set('validationErrors', {});
    this._super(controller, model);
    this._setupInProgressComment(controller, model);
    model.reload();
  },

  _setupInProgressComment(controller, model) {
    const comment = this.get('storage')
                        .getItem(model.get('id'));

    controller.set(
      'inProgressComment',
      (Ember.isEmpty(comment) ? '' : comment)
    );
  },

  _pusherEventsId() {
    // needed for the `wire` and `unwire` method to think we have
    // `ember-pusher/bindings` mixed in
    return this.toString();
  }
});
