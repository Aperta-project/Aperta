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
    LazyLoader.loadScripts([ENV.pdfjs.url]).then(() => {
    });
  },

  refreshPdf:  function() {
    if(this.get('isDestroying')) { return; }
    if (!window.PDFJS) { this.loadPdfJs(); return; }
  }
});
