/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

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
    /*
    *  discussionModel here is actually a paper. The 'atMentionableStaffUsers' function in the paper model returns a promise when called.
    * This mixin is used for both the discussion pane on the manuscript view and the one in the pop out.
    * For the manuscript view, there is an intermediary route (client/app/mixins/discussions/route.js)
    * that resolves the promise returned when you call paper.atMentionableStaffUsers()
    * and passes the resolved promise to this mixin. This doesn't happen for the pop out view.
    * So when  discussionModel.atMentionableStaffUsers is called here it just returns the function declared in the paper model.
    * This is why the code below has to account for both occurences.
    */
    const mentionableStaffUsers = discussionModel.atMentionableStaffUsers;
    if(typeof mentionableStaffUsers === 'function') {
      discussionModel.atMentionableStaffUsers()
        .then(userPromises => Ember.RSVP.all(userPromises))
        .then(staffUsers => controller.set('atMentionableStaffUsers', staffUsers));
    } else {
      controller.set('atMentionableStaffUsers', mentionableStaffUsers);
    }

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
