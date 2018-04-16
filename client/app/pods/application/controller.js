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
import ENV from 'tahi/config/environment';
import pusherConcerns from 'tahi/mixins/controllers/pusher-concerns';

export default Ember.Controller.extend(pusherConcerns, {
  can: Ember.inject.service('can'),
  delayedSave: false,
  isLoggedIn: Ember.computed.notEmpty('currentUser'),
  canViewAdminLinks: false,
  showOverlay: false,
  showFeedbackOverlay: false,
  journals: null,
  canViewPaperTracker: false,
  minimalChrome: false,

  setCanViewPaperTracker: function() {
    if (this.journals === null) {
      return false;
    }
    var that = this;
    this.journals.toArray().forEach(function(journal) {
      that.get('can').can('view_paper_tracker', journal).then( (value) =>
        Ember.run(function() {
          if (value) {
            that.set('canViewPaperTracker', true);
          }
        })
      );
    });
  },

  clearError: Ember.observer('currentPath', function() {
    this.set('error', null);
  }),

  resetScrollPosition: Ember.observer('currentPath', function() {
    window.scrollTo(0, 0);
  }),

  testing: Ember.computed(function() {
    return Ember.testing || ENV.environment === 'test';
  }),

  showSaveStatusDiv: Ember.computed.and('testing', 'delayedSave'),

  specifiedAppName: window.appName,

  actions: {
    showFeedbackOverlay() { this.set('showFeedbackOverlay', true); },
    hideFeedbackOverlay() { this.set('showFeedbackOverlay', false); }
  }
});
