import Ember from 'ember';
import PaperIndexMixin from 'tahi/mixins/views/paper-index';
import LazyLoader from 'ember-cli-lazyloader/lib/lazy-loader';
import ENV from 'tahi/config/environment';

export default Ember.View.extend(PaperIndexMixin, {
  renderEquations: function() {
    return navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
  },

  didInserElement: function() {
    this.loadMathJax();
  },

  didRender: function() {
    this.refreshEquations();
  },

  loadMathJax: function() {
    if (this.renderEquations) {
      LazyLoader.loadScripts([ENV.mathjax.url]).then(() => {
        this.refreshEquations();
      });
    }
  },

  refreshEquations:  function() {
    if (!this.renderEquations) { return; }
    else if (!window.MathJax) { this.loadMathJax(); return; }
    else if (!window.MathJax.Hub) { return; }

    Ember.run.next(() => {
      MathJax.Hub.Queue(['Typeset', MathJax.Hub, this.$()[0]]);
    });
  }

});
