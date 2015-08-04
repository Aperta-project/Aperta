import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Component.extend({
  oldText: null,
  currentBody: null,
  leftText: null,
  rightText: null,

  getRightText() {
    let edited = this.get('compareVersion');
    if (edited) {
      RESTless.get('/api/versioned_texts/' + edited.id).then((response) => {
        this.rightText = response['versioned_text']['text'];
        this.setPaperBody();
      });
    } else {
      this.rightText = null;
      this.setPaperBody();
    }
  },

  showVersion() {
    let version = this.get('selectedVersion');

    if (version) {
      console.log('showVersion', version.id);
      RESTless.get('/api/versioned_texts/' + version.id).then((response) => {
        this.leftText = response['versioned_text']['text'];
        this.setPaperBody();
      });
    }
  },

  setPaperBody() {
    if (this.rightText == null) {
      this.set('paper.currentVersionBody', this.leftText);
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
    let diff = this.SentenceDiff.diff(this.rightText, this.leftText);
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
    this.addObserver('selectedVersion', this, 'showVersion');
    this.addObserver('compareVersion', this, 'getRightText');
  }.on('didInsertElement'),

  versioningModeTransition: Ember.computed.or(
    'transitioning',
    'versioningMode'
  ),

  actions: {
    openVersioningMode() {
      this.set('transitioning', true);
      this.showVersion();
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
