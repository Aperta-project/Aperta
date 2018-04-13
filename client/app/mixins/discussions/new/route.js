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
