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
import Controller from 'ember-controller';
import PaperBase from 'tahi/mixins/controllers/paper-base';
import Discussions from 'tahi/mixins/discussions/route-paths';

const {
  computed,
  computed: { equal }
} = Ember;

export default Controller.extend(PaperBase, Discussions, {
  //sent by paper-new on creation, used to show submission process 1st view
  queryParams: ['firstView'],
  downloadsVisible: false,
  showFeedbackOverlay: false,
  paper: Ember.computed.alias('model'),

  isGradualEngagement: equal('paper.gradualEngagement', true),
  renderEngagementBanner: computed('isGradualEngagement', 'paper.isWithdrawn',
    function() {
      return this.get('paper.gradualEngagement') &&
        !this.get('paper.isWithdrawn');
    }
  ),

  showSubmissionProcess: computed('paper', 'firstView', 'isGradualEngagement',
    function() {
      if (!this.get('isGradualEngagement')) return false;

      if (this.get('firstView') === 'true') {
        // Removes from url. Generally not a good idea to
        // modify a prop inside a CP. Esp since the CP is
        // watching for changes on that prop
        this.set('firstView', undefined);

        return true;
      }

      return false;
    }
  ),

  defaultPreprintTaskOpen: computed('firstView', function () {
    return this.get('firstView') === 'true';
  }),

  showPdfManuscript: computed('paper.fileType', 'paper.file.status',
    function(){
      return (this.get('paper.fileType') === 'pdf') &&
             (this.get('paper.file.status') !== 'error');
    }
  ),

  checkFileType: computed('paper.fileType', function(){
    if (this.get('paper.fileType') === 'pdf'){
      return 'fa-file-pdf-o';
    }
    else {
      return 'fa-file-word-o';
    }
  }),

  showPaperSubmitOverlay: false,

  actions: {
    toggleSubmissionProcess() {
      this.toggleProperty('showSubmissionProcess');
    },

    showPaperSubmitOverlay() {
      this.set('showPaperSubmitOverlay', true);
    },

    hidePaperSubmitOverlay() {
      this.set('showPaperSubmitOverlay', false);
    },

    toggleDownloads() {
      this.toggleProperty('downloadsVisible');
    },

    showFeedbackOverlay() {
      this.set('showFeedbackOverlay', true);
    },

    hideFeedbackOverlay() {
      this.set('showFeedbackOverlay', false);
    },
  }
});
