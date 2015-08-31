import Ember from 'ember';

export default Ember.Component.extend({
  restless: Ember.inject.service('restless'),
  oldText: null,
  currentBody: null,

  reset() {
    // Resets page to viewing a single version
    this.comparisonText = null;
    this.set('paper.comparisonText', null);
    this.set('compareToVersion', null);
  },

  getComparisonText() {
    // Fetches version of the text to compare with the version we're viewing
    const version = this.get('comparisonVersion');

    if (version) {
      const url = '/api/versioned_texts/' + version.id;
      this.get('restless').get(url).then((response) => {
        this.set('paper.comparisonText', response['versioned_text']['text']);
      });
    } else {
      this.reset();
    }
  },

  getViewingText() {
    // Fetches a version of the text to view
    const version = this.get('viewingVersion');

    if (version) {
      const url = '/api/versioned_texts/' + version.id;
      this.get('restless').get(url).then((response) => {
        this.set('paper.viewingText', response['versioned_text']['text']);
      });
    }
  },

  resetter: Ember.on('didInsertElement', function() {
    this.set('viewingVersion', this.get('paper.versions.firstObject'));
    this.reset();
  }),

  actions: {
    changeViewingVersion(version) {
      this.set('viewingVersion', version);
      this.getViewingText();
    },

    changeComparisonVersion(version) {
      this.set('comparisonVersion', version);
      this.getComparisonText();
    }
  }
});
