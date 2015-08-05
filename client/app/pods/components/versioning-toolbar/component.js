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
        //TODOMPM - can we get rid of this timeout?
        setTimeout( function() { that.setCurrentVersionBody(); }, 1000);
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

  getTags: function(element) {
    if (this.isTextNode(element)) {
      return ['',''];
    }

    let tagName = element.nodeName.toLowerCase();
    let regex = new RegExp('<\/' + tagName + '>', 'i');
    let startTag = $(element).clone().empty().prop("outerHTML").replace(regex,'');
    let endTag = '</' + tagName + '>';
    return [startTag, endTag];
  },

  shouldExplode: function(element) {
    if (element.nodeName && !this.isTextNode(element)) {
      return $.inArray(element.nodeName.toLowerCase(), ["p"]) >= 0;
    }
    return false;
  },

  isTextNode: function(element) {
    return element.nodeType === 3;
  },

  explodeElement: function(element) {
    var that = this;
    let elementMap = $(element).contents().map( function(i, element) {
      if (that.isTextNode(element)) {
        return element.textContent.split(/(\S.+?[.!?])/);
      } else {
        return element.outerHTML;
      }
    }).get();
    let tags = that.getTags(element);
    elementMap.unshift(tags[0]);
    elementMap.push(tags[1]);
    return elementMap;
  },

  setupDiffer: function() {
    this.Differ = new JsDiff.Diff();
    var that = this;
    this.Differ.tokenize = function(value) {
      var ourMap = value.contents().map( function(i, element) {
        if (that.shouldExplode(element)) {
          return that.explodeElement(element);
        }
        else if (that.isTextNode(element)) {
          return element.textContent.split(/(\S.+?[.!?])/);
        } else {
          return element.outerHTML;
        }
      }).get();
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
