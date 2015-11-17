import Ember from 'ember';
import DocumentDownload from 'tahi/services/document-download';
import ENV from 'tahi/config/environment';
import Utils from 'tahi/services/utils';

const { computed } = Ember;

export default Ember.Mixin.create({
  restless: Ember.inject.service('restless'),

  subRouteName: 'index',
  versioningMode: false,
  canViewManuscriptManager: false,

  activityIsLoading: false,
  showActivityOverlay: false,
  activityFeed: null,

  showCollaboratorsOverlay: false,
  showWithdrawOverlay: false,

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
      return DocumentDownload.initiate(
        this.get('model.id'),
        downloadType.format
      );
    },

    saveManuscriptTitle() {
      Ember.run.debounce(this, this.save, 500);
    },

    hideActivityOverlay() {
      this.set('showActivityOverlay', false);
    },

    showActivity(type) {
      this.set('activityIsLoading', true);
      this.set('showActivityOverlay', true);
      const url = `/api/papers/${this.get('model.id')}/activity/${type}`;

      this.get('restless').get(url).then((data)=> {
        this.setProperties({
          activityIsLoading: false,
          activityFeed: Utils.deepCamelizeKeys(data.feeds)
        });
      });
    },

    showCollaboratorsOverlay() {
      this.set('showCollaboratorsOverlay', true);
    },

    hideCollaboratorsOverlay() {
      this.set('showCollaboratorsOverlay', false);
    },

    showWithdrawOverlay() {
      this.set('showWithdrawOverlay', true);
    },

    hideWithdrawOverlay() {
      this.set('showWithdrawOverlay', false);
    }
  }
});
