import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Component.extend({
  reset() {
    // Resets page to viewing a single version
    this.comparisonText = null;
    this.set('paper.comparisonText', null);
    this.set('compareToVersion', null);
  },

  getComparisonText() {
    // Fetches version of the text to compare with the version we're viewing
    let version = this.get('comparisonVersion');
    if (version) {
      RESTless.get('/api/versioned_texts/' + version.id).then((response) => {
        this.set('paper.comparisonText', response['versioned_text']['text']);
      });
    } else {
      this.reset();
    }
  },

  getViewingText() {
    // Fetches a version of the text to view
    let version = this.get('viewingVersion');

    if (version) {
      RESTless.get('/api/versioned_texts/' + version.id).then((response) => {
        this.set('paper.viewingText', response['versioned_text']['text']);
      });
    }
  },

  setupObserver: function() {
    this.addObserver('viewingVersion', this, 'getViewingText');
    this.addObserver('comparisonVersion', this, 'getComparisonText');
  }.on('didInsertElement'),

  versioningModeTransition: Ember.computed.or(
    'transitioning',
    'versioningMode'
  ),

  actions: {
    openVersioningMode() {
      this.set('transitioning', true);
      this.reset();

      Ember.run.later(()=>{
        this.set('versioningMode', true);
        this.set('transitioning', false);
      }, 500);
    },

    closeVersioningMode() {
      this.set('versioningMode', false);
    }
  }
});
