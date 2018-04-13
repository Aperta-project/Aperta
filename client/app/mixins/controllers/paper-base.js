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
import deepCamelizeKeys from 'tahi/lib/deep-camelize-keys';

const { computed } = Ember;

export default Ember.Mixin.create({
  restless: Ember.inject.service('restless'),

  subRouteName: 'index',
  versioningMode: false,

  activityIsLoading: false,
  showActivityOverlay: false,
  activityFeed: null,

  showCollaboratorsOverlay: false,
  showWithdrawOverlay: false,

  supportedDownloadFormats: computed(function() {
    return ENV.APP.iHatExportFormats.map(format => {
      return {
        format: format.type,
        display: format.display,
        icon: `svg/${format.type}-icon`
      };
    });
  }),

  pageContainerHTMLClass: computed('paper.editorMode', function() {
    return 'paper-container-' + this.get('paper.editorMode');
  }),

  save() {
    this.get('paper').save();
  },

  actions: {
    hideActivityOverlay() {
      this.set('showActivityOverlay', false);
    },

    showActivityOverlay(type) {
      this.set('activityIsLoading', true);
      this.set('showActivityOverlay', true);
      const url = `/api/papers/${this.get('paper.id')}/activity/${type}`;

      this.get('restless').get(url).then((data)=> {
        this.setProperties({
          activityIsLoading: false,
          activityFeed: deepCamelizeKeys(data.feeds)
        });
      });
    },

    showCollaboratorsOverlay() {
      this.set('showCollaboratorsOverlay', true);
    },

    hideCollaboratorsOverlay() {
      this.set('showCollaboratorsOverlay', false);
    },

    showWithdrawOverlay() {
      this.set('showWithdrawOverlay', true);
    },

    hideWithdrawOverlay() {
      this.set('showWithdrawOverlay', false);
    }
  }
});
