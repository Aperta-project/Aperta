import Ember from 'ember';
import DocumentDownload from 'tahi/services/document-download';
import ENV from 'tahi/config/environment';

const { computed } = Ember;

export default Ember.Mixin.create({
  needs: ['application', 'paper'],
  isAdmin: Ember.computed.alias('currentUser.siteAdmin'),
  canViewManuscriptManager: false,

  downloadsVisible: false,
  contributorsVisible: false,
  versionsVisible: false,
  subNavVisible: false,

  supportedDownloadFormats: computed(function() {
    return ENV.APP.iHatExportFormats.map(formatType => {
      return {format: formatType, icon: `svg/${formatType}-icon`};
    });
  }),

  downloadLink: computed('model.id', function() {
    return '/papers/' + this.get('model.id') + '/download';
  }),

  logoUrl: computed('model.journal.logoUrl', function() {
    let logoUrl = this.get('model.journal.logoUrl');
    return (/default-journal-logo/.test(logoUrl)) ? false : logoUrl;
  }),

  pageContainerHTMLClass: computed('model.editorMode', function() {
    return 'paper-container-' + this.get('model.editorMode');
  }),

  // Tasks:
  assignedTasks: computed('model.tasks.@each', function() {
    let metadataTasks = this.get('metadataTasks');

    return this.get('model.tasks').filter((task) => {
      return task.get('participations').mapBy('user').contains(this.get('currentUser'));
    }).filter(function(t) {
      return !metadataTasks.contains(t);
    });
  }),

  metadataTasks: computed('model.tasks.@each.role', function() {
    return this.get('model.tasks').filter((task) => {
      return task.get('isMetadataTask');
    });
  }),

  taskSorting:         ['phase.position', 'position'],
  sortedMetadataTasks: Ember.computed.sort('metadataTasks',   'taskSorting'),
  sortedAssignedTasks: Ember.computed.sort('assignedTasks', 'taskSorting'),

  noTasks: computed('assignedTasks.@each', 'metadataTasks.@each', function() {
    return [this.get('assignedTasks'), this.get('metadataTasks')].every((taskGroup)=> {
      return Ember.isEmpty(taskGroup);
    });
  }),

  subNavVisibleDidChange: Ember.observer('subNavVisible', function() {
    if (this.get('subNavVisible')) {
      $('.paper-toolbar').css('top', '103px');
      $('html').addClass('control-bar-sub-nav-active');
    } else {
      $('.paper-toolbar').css('top', '60px');
      $('html').removeClass('control-bar-sub-nav-active');
    }
  }),

  actions: {
    'export': function(downloadType) {
      return DocumentDownload.initiate(this.get('model.id'), downloadType.format);
    },

    hideVisible() {
      this.setProperties({
        contributorsVisible: false,
        downloadsVisible: false,
        versionsVisible: false
      });
    },

    showVersions() {
      this.send('hideVisible');
      this.set('versionsVisible', true);
    },

    showContributors() {
      this.send('hideVisible');
      this.set('contributorsVisible', true);
    },

    showDownloads() {
      this.send('hideVisible');
      this.set('downloadsVisible', true);
    },

    showSubNav(sectionName) {
      if (this.get('subNavVisible') && this.get(sectionName + 'Visible')) {
        this.send('hideSubNav');
      } else {
        this.set('subNavVisible', true);
        this.send('show' + (sectionName.capitalize()));
      }
    },

    hideSubNav() {
      this.set('subNavVisible', false);
      this.send('hideVisible');
    },

    toggleVersioningMode() {
      this.toggleProperty('model.versioningMode');
      this.send('showSubNav', 'versions');
    },

    withdrawManuscript() {
      this.send('showConfirmWithdrawOverlay');
    }

  }
});
