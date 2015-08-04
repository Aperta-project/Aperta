import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Component.extend({
  nowViewingText: null,
  compareToText: null,

  getCompareToText() {
    let version = this.get('compareToVersion');
    if (version) {
      RESTless.get('/api/versioned_texts/' + version.id).then((response) => {
        this.compareToText = response['versioned_text']['text'];
        this.setCurrentVersionBody();
      });
    } else {
      this.compareToText = null;
      this.set('paper.diff', null);
      this.setCurrentVersionBody();
    }
  },

  getNowViewingVersion() {
    let version = this.get('nowViewingVersion');

    if (version) {
      RESTless.get('/api/versioned_texts/' + version.id).then((response) => {
        this.nowViewingText = response['versioned_text']['text'];
        this.setCurrentVersionBody();
      });
    }
  },

  setCurrentVersionBody() {
    if (this.compareToText === null) {
      this.set('paper.currentVersionBody', this.nowViewingText);
    }
    else {
      let diff = this.Differ.diff(this.compareToText, this.nowViewingText);
      this.set('paper.diff', diff);
    }
  },

  setupObserver: function() {
    this.addObserver('nowViewingVersion', this, 'getNowViewingVersion');
    this.addObserver('compareToVersion', this, 'getCompareToText');
  }.on('didInsertElement'),

  setupDiffer: function() {
    this.Differ = new JsDiff.Diff();
    this.Differ.tokenize = function(value) {
      return value.split(/(\S.+?(?:[.!?]|<.*?>))/);
    };
  }.on('didInsertElement'),

  versioningModeTransition: Ember.computed.or(
    'transitioning',
    'versioningMode'
  ),

  actions: {
    openVersioningMode() {
      this.set('transitioning', true);
      this.getNowViewingVersion();

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
