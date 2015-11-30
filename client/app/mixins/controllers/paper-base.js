import Ember from 'ember';
import DocumentDownload from 'tahi/services/document-download';
import ENV from 'tahi/config/environment';

const { computed } = Ember;

export default Ember.Mixin.create({
  subRouteName: 'index',
  versioningMode: false,
  canViewManuscriptManager: false,

  supportedDownloadFormats: computed(function() {
    return ENV.APP.iHatExportFormats.map(format => {
      return {format: format.type, display: format.display, icon: `svg/${format.type}-icon`};
    });
  }),

  pageContainerHTMLClass: computed('model.editorMode', function() {
    return 'paper-container-' + this.get('model.editorMode');
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
