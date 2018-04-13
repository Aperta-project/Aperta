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
import LazyLoader from 'tahi/lib/lazy-loader';
import ENV from 'tahi/config/environment';
import { paperDownloadPath } from 'tahi/utils/api-path-helpers';

const {
  observer,
} = Ember;

// The template for this component comes from the pdf.js viewer template
// (viewer.html). It was copied into the template and then edited to suit our
// needs. The differences are primarily in the toolbar. We have removed some of
// the generic viewer functionality that was not needed on PLOS.

export default Ember.Component.extend({
  eventBus: Ember.inject.service('event-bus'),
  paper: null, // passed-in
  classNames: [],

  didRender() {
    this._super(...arguments);
    Ember.run.scheduleOnce('afterRender', this, this.refreshPdf);
  },

  fileChanged: observer('paper.file.fileHash', function() {
    this.refreshPdf();
  }),

  loadPdf: function() {
    const url = paperDownloadPath({
      paperId: this.get('paper.id'),
      format: 'pdf',
      versionedTextId: this.get('version.id')
    });
    window.PDFJS.webViewerLoad(url);
  },

  loadPdfJs: function() {

    LazyLoader.loadScripts([window.pdfviewerPath]).then(() => {
      this.get('eventBus').subscribe('split-pane-resize', this, webViewerResize);

      var pdfjsroot = '/assets/pdfjsviewer/';
      window.PDFJS.workerSrc = pdfjsroot + 'pdf.worker.js';
      window.PDFJS.imageResourcesPath = pdfjsroot + 'images/';
      window.PDFJS.cMapUrl = pdfjsroot + 'cmaps/';
      window.PDFJS.plosErrorCallback = () => {
        this.set('paper.file.status', 'error');
        this.set('paper.previewFail', true);
      };

      this.loadPdf();
    });
  },

  refreshPdf:  function() {
    if(this.get('isDestroying')) { return; }
    if (!window.PDFJS) { this.loadPdfJs(); }
    else { this.loadPdf(); }
  }
});
