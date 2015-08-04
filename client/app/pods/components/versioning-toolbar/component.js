import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Component.extend({
  oldText: null,
  currentBody: null,
  fromText: null,
  compareToText: null,

  getCompareToText() {
    let edited = this.get('compareToVersion');
    if (edited) {
      RESTless.get('/api/versioned_texts/' + edited.id).then((response) => {
        this.compareToText = response['versioned_text']['text'];
        this.setPaperBody();
      });
    } else {
      this.compareToText = null;
      this.setPaperBody();
    }
  },

  getFromVersion() {
    let version = this.get('fromVersion');

    if (version) {
      RESTless.get('/api/versioned_texts/' + version.id).then((response) => {
        this.fromText = response['versioned_text']['text'];
        this.setPaperBody();
      });
    }
  },

  setPaperBody() {
    if (this.compareToText == null) {
      this.set('paper.currentVersionBody', this.fromText);
    }
    else {
      this.set('paper.currentVersionBody', this.setDiffedBody());
    }
  },

  ourDiff: function() {
    console.log('our diff');
    this.SentenceDiff = new JsDiff.Diff();
    this.SentenceDiff.tokenize = function(value) {
      return value.split(/(\S.+?(?:[.!?]|<.*?>))/);
    };
  }.on('didInsertElement'),

  setDiffedBody() {
    let body = "";
    console.log(this.SentenceDiff);
    let diff = this.SentenceDiff.diff(this.compareToText, this.fromText);
    console.log(diff);
    return "<span>" + _.map(diff, this.styleDiffChunk, this).join("");
  },

  styleDiffChunk(chunk) {
    return (this.makeSpan(chunk) +
            chunk.value.replace(/<.*?>/g, "</span>$&" + this.makeSpan(chunk)) +
            "</span>");
  },

  makeSpan(chunk) {
    let cssClass = "";
    if (chunk.added) {
      cssClass="added";
    }
    if (chunk.removed) {
      cssClass="removed";
    }
    return "<span class='" + cssClass + "'>";
  },

  setupObserver: function() {
    this.addObserver('fromVersion', this, 'getFromVersion');
    this.addObserver('compareToVersion', this, 'getCompareToText');
  }.on('didInsertElement'),

  versioningModeTransition: Ember.computed.or(
    'transitioning',
    'versioningMode'
  ),

  actions: {
    openVersioningMode() {
      this.set('transitioning', true);
      this.getFromVersion();
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
