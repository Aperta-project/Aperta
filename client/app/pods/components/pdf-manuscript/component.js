import Ember from 'ember';
import LazyLoader from 'tahi/lib/lazy-loader';
import ENV from 'tahi/config/environment';

export default Ember.Component.extend({
  eventBus: Ember.inject.service('event-bus'),
  paper: null, // passed-in
  classNames: [],

  didRender() {
    this._super(...arguments);
    Ember.run.scheduleOnce('afterRender', this, this.refreshPdf);
  },

  loadPdfJs: function() {
    LazyLoader.loadScripts([window.pdfviewerPath]).then(() => {
      console.log('PDFJS-viewer loaded');
      this.get('eventBus').subscribe('split-pane-resize', this, webViewerResize);

      var pdfjscdn = '//bowercdn.net/c/pdf.js-viewer-0.3.3/';
      PDFJS.workerSrc = pdfjscdn + 'pdf.worker.js';
      PDFJS.imageResourcesPath = pdfjscdn + 'images/';
      PDFJS.cMapUrl = pdfjscdn + 'cmaps/';
      var download = this.get('paper.id') + '/download.pdf';
      PDFJS.webViewerLoad(download);
    });
  },

  refreshPdf:  function() {
    if(this.get('isDestroying')) { return; }
    if (!window.PDFJS) { this.loadPdfJs(); }
  }
});
