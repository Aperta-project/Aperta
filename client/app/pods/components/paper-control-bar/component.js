import Ember from 'ember';

const { computed } = Ember;

export default Ember.Component.extend({
  classNames: ['control-bar'],
  classNameBindings: ['submenuVisible:control-bar--sub-items-active'],

  hasJournalLogo: computed.notEmpty('paper.journal.logoUrl'),
  logoUrl: computed.alias('paper.journal.logoUrl'),
  paperWithdrawn: computed.equal('paper.publishingState', 'withdrawn'),
  submenuVisible: false,
  contributorsVisible: false,
  downloadsVisible: false,
  versionsVisible: false,

  downloadLink: computed('paper.id', function() {
    return '/papers/' + this.get('paper.id') + '/download';
  }),

  resetSubmenuFlags() {
    this.setProperties({
      contributorsVisible: false,
      downloadsVisible: false
    });
  },

  showSection(sectionName) {
    this.resetSubmenuFlags();
    this.set('submenuVisible', true);
    this.set(`${sectionName}Visible`, true);
  },

  actions: {
    showSubNav(sectionName) {
      if (this.get('submenuVisible') && this.get(`${sectionName}Visible`)) {
        this.resetSubmenuFlags();
        this.set('submenuVisible', false);
      } else {
        this.showSection(sectionName);
      }
    },

    toggleVersioningMode() {
      this.toggleProperty('paper.versioningMode');
      this.send('showSubNav', 'versions');
    },

    addContributors(activity) {
      this.sendAction('addContributors', activity);
    },

    showActivity(activity) {
      this.sendAction('showActivity', activity);
    },

    exportDocument(downloadType) {
      this.sendAction('exportDocument', downloadType);
    },

    withdrawManuscript() {
      this.sendAction('showWithdrawOverlay');
    }
  }
});
