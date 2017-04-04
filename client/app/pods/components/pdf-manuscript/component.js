import Ember from 'ember';
import LazyLoader from 'tahi/lib/lazy-loader';
import ENV from 'tahi/config/environment';
import { paperDownloadPath } from 'tahi/utils/api-path-helpers';

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

  loadPdf: function() {
  },

  pdfUrl: Ember.computed('paper.id', 'version.id', function() {
    return paperDownloadPath({
      paperId: this.get('paper.id'),
      format: 'pdf',
      versionedTextId: this.get('version.id')
    });
  }),

  loadPdfJs: function() {
    // uses the current version of pdf.js hosted by mozilla
    // TODO: self-host these resources
    var pdfjsroot = 'http://mozilla.github.io/pdf.js/build/pdf.js';
    const workerSrc = 'http://mozilla.github.io/pdf.js/build/pdf.worker.js';

    LazyLoader.loadScripts([pdfjsroot]).then(() => {
      window.PDFJS.workerSrc = workerSrc;
      window.PDFJS.getDocument(this.get('pdfUrl')).then(function(pdf) {

        // Only loads the first page of the PDF.
        // TODO: make more pages load
        pdf.getPage(1).then(function(page) {

          var scale = 1.5;
          var viewport = page.getViewport(scale);

          // Prepare canvas using PDF page dimensions
          var canvas = document.getElementById('the-canvas');
          var context = canvas.getContext('2d');
          canvas.height = viewport.height;
          canvas.width = viewport.width;

          // Render PDF page into canvas context
          var renderContext = {
            canvasContext: context,
            viewport: viewport
          };
          page.render(renderContext);
        });
      });
    });
  },

  refreshPdf:  function() {
    if(this.get('isDestroying')) { return; }
    if (!window.PDFJS) { this.loadPdfJs(); }
    else { this.loadPdf(); }
  }
});
