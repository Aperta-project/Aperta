import Ember from 'ember';
import LazyLoader from 'tahi/lib/lazy-loader';
import ENV from 'tahi/config/environment';

export default Ember.Component.extend({
  paper: null, // passed-in
  classNames: ['manuscript'],

  didRender() {
    this._super(...arguments);
    Ember.run.scheduleOnce('afterRender', this, this.refreshPdf);
  },

  loadPdfJs: function() {
    LazyLoader.loadScripts(['/assets/pdfviewer.js']).then(() => {
      console.log('PDFJS-viewer loaded');
      PDFJS.workerSrc = '/assets/pdfjsviewer-worker.js';
      var download = this.get('paper.id') + '/download.pdf';
      PDFJS.webViewerLoad(download);
    });
  },

  refreshPdf:  function() {
    if(this.get('isDestroying')) { return; }
    if (!window.PDFJS) { this.loadPdfJs(); }
  }
});
