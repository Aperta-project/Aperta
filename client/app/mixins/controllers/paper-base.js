import Ember from 'ember';
import DocumentDownload from 'tahi/services/document-download';
import ENV from 'tahi/config/environment';

const { computed } = Ember;

export default Ember.Mixin.create({
  needs: ['application', 'paper'],
  isAdmin: Ember.computed.alias('currentUser.siteAdmin'),
  canViewManuscriptManager: false,

  supportedDownloadFormats: computed(function() {
    return ENV.APP.iHatExportFormats.map(formatType => {
      return {format: formatType, icon: `svg/${formatType}-icon`};
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
    }
  }
});
