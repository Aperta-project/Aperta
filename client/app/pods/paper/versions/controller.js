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
import PaperBase from 'tahi/mixins/controllers/paper-base';
import Discussions from 'tahi/mixins/discussions/route-paths';

export default Ember.Controller.extend(PaperBase, Discussions,  {
  queryParams: ['selectedVersion1', 'selectedVersion2'],
  routing: Ember.inject.service('-routing'),
  paper: Ember.computed.alias('model'),

  taskToDisplay: null,
  showTaskOverlay: false,
  previousURL: null,
  showPdfManuscript: Ember.computed('paper.fileType', 'viewingVersion.fileType',
    function(){
      return this.get('viewingVersion.fileType') ?
        this.get('viewingVersion.fileType') === 'pdf' :
        this.get('paper.fileType') === 'pdf';
    }
  ),
  comparisonIsPdf: Ember.computed.equal('comparisonVersion.fileType', 'pdf'),
  downloadsVisible: false,

  generateTaskVersionURL(task) {
    return this.get('routing.router._routerMicrolib').generate(
      'paper.task.version',
      task.get('paper'),
      task.get('id'),
      {
        queryParams: {
          selectedVersion1: this.get('selectedVersion1'),
          selectedVersion2: this.get('selectedVersion2')
        }
      }
    );
  },

  generatePaperVersionURL(paper) {
    return this.get('routing.router._routerMicrolib').generate(
      'paper.versions',
      paper,
      {
        queryParams: {
          selectedVersion1: this.get('selectedVersion1'),
          selectedVersion2: this.get('selectedVersion2')
        }
      }
    );
  },

  actions: {
    viewCard(task) {
      const r = this.get('routing.router._routerMicrolib');
      const newURL = this.generateTaskVersionURL(task);
      const previousURL = this.generatePaperVersionURL(task.get('paper'));

      r.updateURL(newURL);

      this.setProperties({
        previousURL: previousURL,
        taskToDisplay: task,
        showTaskOverlay: true
      });
    },

    hideTaskOverlay() {
      this.get('routing.router._routerMicrolib')
          .updateURL(this.get('previousURL'));

      this.set('showTaskOverlay', false);
    },

    setViewingVersion(version) {
      this.set('viewingVersion', version);
      this.set(
        'selectedVersion1',
        `${version.get('majorVersion')}.${version.get('minorVersion')}`);
    },

    setComparisonVersion(version) {
      this.set('comparisonVersion', version);
      this.set(
        'selectedVersion2',
        `${version.get('majorVersion')}.${version.get('minorVersion')}`);
    },

    setQueryParam(key, value) {
      this.set(key, value);
    },

    toggleDownloads() {
      this.toggleProperty('downloadsVisible');
    }
  }
});
