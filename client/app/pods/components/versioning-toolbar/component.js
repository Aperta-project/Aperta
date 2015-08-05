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
        this.set('paper.compareToText', this.compareToText);
        var that = this;
        setTimeout( function() { that.setCurrentVersionBody(); }, 1000);
        //this.setCurrentVersionBody();
      });
    } else {
      this.compareToText = null;
      this.set('paper.diff', null);
      this.set('paper.compareToText', null);
      this.setCurrentVersionBody();
    }
  },

  getNowViewingVersion() {
    let version = this.get('nowViewingVersion');

    if (version) {
      RESTless.get('/api/versioned_texts/' + version.id).then((response) => {
        this.nowViewingText = response['versioned_text']['text'];
        this.set('paper.nowViewingText', this.nowViewingText);
        this.setCurrentVersionBody();
      });
    }
  },

  setCurrentVersionBody() {
    if (this.compareToText === null) {
      this.set('paper.currentVersionBody', this.nowViewingText);
      this.set('paper.nowViewingText', this.nowViewingText);
    }
    else {
      let compareToText = $("#paper-version-2");
      let nowViewingText = $("#paper-version-1");
      let diff = this.Differ.diff(compareToText, nowViewingText);
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
      console.log("children", value.contents());
      var ourMap = value.contents().map( function(i, element) {
        console.log("element", element, element.textContent);
        if ($(element).is("p")) {
          console.log("p", element);
          let paragraphMap = $(element).contents().map( function(i, element) {
            if (element.nodeType === 3) {
              return element.textContent.split(/(\S.+?[.!?])/);
            } else {
              return element.outerHTML;
            }
          }).get();
          console.log("p2", $(element));
          let startTag = $(element).clone().empty().prop("outerHTML").replace(/<\/p>/i,'');
          paragraphMap.unshift(startTag);
          paragraphMap.push("</p>");
          return paragraphMap;
        }
        else if (element.outerHTML) {
          return element.outerHTML;
        } else if (element.nodeType === 3){
          return element.textContent.split(/(\S.+?[.!?])/);
        }
      }).get();

      console.log("our map", ourMap);
      return _.flatten(ourMap);
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
