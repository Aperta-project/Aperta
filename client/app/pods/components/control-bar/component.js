import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['control-bar'],
  classNameBindings: ['subNavVisible:control-bar-sub-nav-active'],
  hasJournalLogo: Ember.computed.notEmpty('paper.journal.logoUrl'),
  subNavVisible: false,
  contributorsVisible: false,
  downloadsVisible: false,
  versionsVisible: false,

  downloadLink: Ember.computed('paper.id', function() {
    return '/papers/' + this.get('paper.id') + '/download';
  }),

  hideVisible() {
    this.setProperties({
      contributorsVisible: false,
      downloadsVisible: false,
      versionsVisible: false
    });
  },

  hideSubNav() {
    this.set('subNavVisible', false);
    this.hideVisible();
  },

  showVersions() {
    this.hideVisible();
    this.set('versionsVisible', true);
  },

  showContributors() {
    this.hideVisible();
    this.set('contributorsVisible', true);
  },

  showDownloads() {
    this.hideVisible();
    this.set('downloadsVisible', true);
  },

  actions: {

    showSubNav(sectionName) {
      if (this.get('subNavVisible') && this.get(sectionName + 'Visible')) {
        this.hideSubNav();
      } else {
        this.set('subNavVisible', true);
        this.trigger('show' + (sectionName.capitalize()));
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
    }
  }
});
