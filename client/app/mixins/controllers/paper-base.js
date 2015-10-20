import Ember from 'ember';
import DocumentDownload from 'tahi/services/document-download';
import ENV from 'tahi/config/environment';

const { computed } = Ember;

export default Ember.Mixin.create({
  subRouteName: 'index',
  versioningMode: false,
  canViewManuscriptManager: false,
  cannotEditTitle: computed.equal('model.publishingState', 'submitted'),

  supportedDownloadFormats: computed(function() {
    return ENV.APP.iHatExportFormats.map(formatType => {
      return {format: formatType, icon: `svg/${formatType}-icon`};
    });
  }),

  pageContainerHTMLClass: computed('model.editorMode', function() {
    return 'paper-container-' + this.get('model.editorMode');
  }),

  processingMessage: computed('model.status', function() {
    const isProcessing = this.get('model.status') === 'processing';
    return isProcessing ? 'Processing Manuscript' : null;
  }),

  save() {
    this.get('model').save();
  },

  actions: {
    exportDocument(downloadType) {
      return DocumentDownload.initiate(this.get('model.id'), downloadType.format);
    },

    saveManuscriptTitle() {
      Ember.run.debounce(this, this.save, 500);
    }
  }
});
