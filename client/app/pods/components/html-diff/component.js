import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Component.extend({
  classNames: ['html-diff'],

  // This is the text of the version being viewed (left dropdown)
  viewingText: null,

  // This is the text of the version we're comparing with (right dropdown)
  comparisonText: null,

  tokenizeInsideElements: ['p'],

  sentenceDelimiter: /(\S.+?[.!?,;]\s*)/g,

  manuscript: function() {
    if (!this.get('comparisonText')) {
      return this.get('viewingText');
    } else {
      return this.diff();
    }
  }.property('comparisonText', 'viewingText'),

  diff() {
    // Calculate the diff
    let diff = this.Differ.diff(
      this.get('comparisonText'),
      this.get('viewingText'));

    // Style the diff
    return _.map(diff, (chunk) => {
      let html = this.addDiffStylingClass(chunk);
      return this.unForceValidHTML(html);
    }).join('');
  },

  setupDiffer: function() {
    this.Differ = new JsDiff.Diff();
    var that = this;
    this.Differ.tokenize = function(html) {
      let elements = $(html).toArray();
      let tokens = _.map(elements, that.tokenizeElement, that);
      tokens =  _.flatten(tokens);
      console.log(tokens);
      return tokens;
    };
  }.on('didInsertElement'),

  addDiffStylingClass(chunk) {
    let cssClass = null;
    if (chunk.added) {
      cssClass = "added";
    } else if (chunk.removed) {
      cssClass = "removed";
    } else {
      cssClass = "unchanged";
    }

    let elements = $(chunk.value).addClass(cssClass).toArray();
    return _.pluck(elements, 'outerHTML').join("");
  },

  // TOKENIZING

  // For tags that we diff *inside* of, we will necessarily have
  // chunks that contain only the opening or only the closing tag. For
  // the sake of future manipulation, we need every chunk to be valid,
  // complete HTML.
  //
  // So (warning: gross parts ahead) for any tag we diff inside, we
  // replace the opening and closing tag with an *empty matched pair*.
  // Then, right before we spit the final diffed HTML back out, we
  // turn each matched pair back into a single opening or closing tag.
  //
  // Beatings, threats, and poison-pen notes can be sent to Sam
  // Bleckley. Sorry. - 08/06/2015

  forceValidHTML(element, tokens) {
    // Adda the fake tag pairs
    let tagName = element.nodeName.toLowerCase();
    tokens.unshift("<fake-open-" + tagName + "></fake-open-" + tagName + ">");
    tokens.push("<fake-close-" + tagName + "></fake-close-" + tagName + ">");
  },

  unForceValidHTML: function(value) {
    // Removea the fake tag pairs
    _.each(this.tokenizeInsideElements, (elt) => {
      value = value.replace((new RegExp("</fake-open-" + elt + ">")), "");
      value = value.replace((new RegExp("<fake-close-" + elt + ".*?>")), "");
      value = value.replace((new RegExp("fake-open-" + elt)), elt);
      value = value.replace((new RegExp("fake-close-" + elt)), elt);
    });
    return value;
  },

  shouldRecur(element) {
    // Is this an element we want to diff inside (like a <p>), or
    // should we treat it atomically -- like a figure, or an equation?
    if (element.nodeName && !this.isTextNode(element)) {
      return this.tokenizeInsideElements.indexOf(element.nodeName.toLowerCase()) >= 0;
    }
    return false;
  },

  isTextNode(element) {
    return element.nodeType === 3;
  },

  tokenizeElement: function(element) {
    if (this.shouldRecur(element)) {
      let elts = $(element).contents().toArray();
      let tokens = _.map(elts, this.tokenizeElement, this);
      this.forceValidHTML(element, tokens);
      return tokens;

    } else if (this.isTextNode(element)) {
      // Split the text into sentence fragments.
      let chunks = element.textContent.split(this.sentenceDelimiter);
      return _.map(chunks, (e) => { return "<span>" + e + "</span>"; });

    } else {
      return element.outerHTML;
    }
  }
});
