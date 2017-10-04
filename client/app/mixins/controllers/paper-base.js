import Ember from 'ember';
import ENV from 'tahi/config/environment';
import deepCamelizeKeys from 'tahi/lib/deep-camelize-keys';

const { computed } = Ember;

export default Ember.Mixin.create({
  restless: Ember.inject.service('restless'),

  subRouteName: 'index',
  versioningMode: false,

  activityIsLoading: false,
  showActivityOverlay: false,
  activityFeed: null,

  showCollaboratorsOverlay: false,
  showWithdrawOverlay: false,

  supportedDownloadFormats: computed(function() {
    return ENV.APP.iHatExportFormats.map(format => {
      return {
        format: format.type,
        display: format.display,
        icon: `svg/${format.type}-icon`
      };
    });
  }),

  pageContainerHTMLClass: computed('paper.editorMode', function() {
    return 'paper-container-' + this.get('paper.editorMode');
  }),

  save() {
    this.get('paper').save();
  },

  actions: {
    hideActivityOverlay() {
      this.set('showActivityOverlay', false);
    },

    showActivityOverlay(type) {
      this.set('activityIsLoading', true);
      this.set('showActivityOverlay', true);
      const url = `/api/papers/${this.get('paper.id')}/activity/${type}`;

      this.get('restless').get(url).then((data)=> {
        this.setProperties({
          activityIsLoading: false,
          activityFeed: deepCamelizeKeys(data.feeds)
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
