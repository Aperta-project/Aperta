import Ember from 'ember';
import LazyLoader from 'tahi/lib/lazy-loader';
import ENV from 'tahi/config/environment';

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

  loadPdfUrl(url, pdfjsViewerLoad) {
    Ember.$.ajax({
      url: url,
      statusCode: {
        200: (data)=>{
          pdfjsViewerLoad(data.url);
        },
        500: ()=>{
          alert('PDF retrieval failed');
        }
      }
    });
  },

  loadPdf: function() {
    var url = '/api/papers/'
      + this.get('paper.id')
      + '/status/'
      + this.get('paper.id')
      + '?export_format=pdf&job_id=source';
    this.loadPdfUrl(url, window.PDFJS.webViewerLoad);
  },

  loadPdfJs: function() {
    LazyLoader.loadScripts([window.pdfviewerPath]).then(() => {
      this.get('eventBus').subscribe('split-pane-resize', this, webViewerResize);

      var pdfjsroot = '/assets/pdfjsviewer/';
      window.PDFJS.workerSrc = pdfjsroot + 'pdf.worker.js';
      window.PDFJS.imageResourcesPath = pdfjsroot + 'images/';
      window.PDFJS.cMapUrl = pdfjsroot + 'cmaps/';

      this.loadPdf();
    });
  },

  refreshPdf:  function() {
    if(this.get('isDestroying')) { return; }
    if (!window.PDFJS) { this.loadPdfJs(); }
    else { this.loadPdf(); }
  }
});
