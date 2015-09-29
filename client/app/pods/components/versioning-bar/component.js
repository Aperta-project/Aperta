import Ember from 'ember';

export default Ember.Component.extend({
  restless: Ember.inject.service('restless'),
  reset() {
    // Resets page to viewing a single version
    this.comparisonText = null;
    this.set('paper.comparisonText', null);
    this.set('compareToVersion', null);
  },

  resetter: Ember.on('didInsertElement', function() {
    this.set('viewingVersion', this.get('paper.versions.firstObject'));
    this.reset();
  }),

  actions: {
    changeViewingVersion(version) {
      if (version) {
        this.set('paper.viewingText', version.get('text'));
      } else {
        this.reset();
      }
    },

    changeComparisonVersion(version) {
      if (version) {
        this.set('paper.comparisonText', version.get('text'));
      } else {
        this.reset();
      }
    }
  }
});
