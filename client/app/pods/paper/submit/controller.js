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
import { paperDownloadPath } from 'tahi/utils/api-path-helpers';

export default Ember.Controller.extend({
  flash: Ember.inject.service(),
  restless: Ember.inject.service(),
  showFeedbackOverlay: false,
  paperSubmitted: false,
  previousPublishingState: null,
  isFirstFullSubmission: Ember.computed.equal(
    'previousPublishingState', 'invited_for_full_submission'
  ),

  paper: Ember.computed.alias('model.paper'),
  tasks: Ember.computed.alias('model.tasks'),

  preprintOptIn: Ember.computed.alias('paper.preprintOptIn'),

  fileDownloadUrl: Ember.computed('paper', function() {
    return paperDownloadPath({ paperId: this.get('paper.id'), format: 'pdf_with_attachments' });
  }),

  coAuthorsSort: ['position:asc'],
  authors: Ember.computed.union('paper.authors', 'paper.groupAuthors'),
  coAuthors: Ember.computed.filter('authors.@each', function(author) {
    return author.get('position') > 1;
  }),
  sortedCoAuthors: Ember.computed.sort('coAuthors', 'coAuthorsSort'),
  firstAuthor: Ember.computed('paper.authors', function() {
    return this.get('paper.authors.firstObject');
  }),

  recordPreviousPublishingState: function () {
    this.set('previousPublishingState', this.get('paper.publishingState'));
  },

  showFeedbackOverlayFunc() {
    this.set('showFeedbackOverlay', true);
  },

  setPaperStateAsSubmitted() {
    this.set('paperSubmitted', true);
  },

  actions: {
    submit() {
      this.recordPreviousPublishingState();
      this.get('restless').putUpdate(this.get('paper'), '/submit').then(() => {
        this.setPaperStateAsSubmitted();
        this.showFeedbackOverlayFunc();
      }, (arg) => {
        const status = arg.status;
        const model = arg.model;
        let message;
        const errors = model ? model.get('errors.messages') : arg.errors;
        switch (status) {
        case 422:
          message = errors + ' You should probably reload.';
          break;
        case 403:
          message = 'You weren\'t authorized to do that';
          break;
        default:
          message = 'There was a problem saving. Please reload.';
        }

        this.get('flash').displayRouteLevelMessage('error', message);
      });
    },

    hideFeedbackOverlay() {
      this.set('showFeedbackOverlay', false);
      this.transitionToRoute('paper.index', this.get('paper.shortDoi'));
    },

    close() {
      this.attrs.close();
    }
  }
});
