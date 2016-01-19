import Ember from 'ember';
import PaperIndexMixin from 'tahi/mixins/views/paper-index';
import LazyLoader from 'ember-cli-lazyloader/lib/lazy-loader';
import ENV from 'tahi/config/environment';

export default Ember.View.extend(PaperIndexMixin, {
  renderEquations: function() {
    return navigator.userAgent.toLowerCase().indexOf('chrome') > -1;
  },

  didRender: function() {
    this.refreshEquations();
  }.observes('controller.model.body'),

  loadMathJax: function() {
    if (this.renderEquations()) {
      LazyLoader.loadScripts([ENV.mathjax.url]).then(() => {
        this.refreshEquations();
      });
    }
  },

  refreshEquations:  function() {
    if (!this.renderEquations()) { return; }
    else if (!window.MathJax) { this.loadMathJax(); return; }
    else if (!window.MathJax.Hub) { return; }

    var view = this.$()[0];
    Ember.run.next(() => {
      MathJax.Hub.Queue(['Typeset', MathJax.Hub, view]);
    });
  }

});
