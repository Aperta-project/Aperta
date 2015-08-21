import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['control-bar'],
  classNameBindings: ['subNavVisible:control-bar-sub-nav-active'],
  hasJournalLogo: Ember.computed.notEmpty('paper.journal.logoUrl'),
  subNavVisible: false,
  versionsVisible: false,

  actions: {

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

    hideVisible() {
      this.setProperties({
        contributorsVisible: false,
        downloadsVisible: false,
        versionsVisible: false
      });
    },

    toggleVersioningMode() {
      this.toggleProperty('paper.versioningMode');
      this.send('showSubNav', 'versions');
    },

    showVersions() {
      this.send('hideVisible');
      this.set('versionsVisible', true);
    }
  }
});
