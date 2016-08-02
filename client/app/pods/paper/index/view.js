import Ember from 'ember';
import LazyLoader from 'ember-cli-lazyloader/lib/lazy-loader';
import ENV from 'tahi/config/environment';

export default Ember.View.extend({
  didRender: function() {
    this.refreshEquations();
  }.observes('controller.model.body'),

  loadMathJax: function() {
    LazyLoader.loadScripts([ENV.mathjax.url]).then(() => {
      this.refreshEquations();
    });
  },

  refreshEquations:  function() {
    if (!window.MathJax) { this.loadMathJax(); return; }
    else if (!window.MathJax.Hub) { return; }

    var view = this.$()[0];
    Ember.run.next(() => {
      MathJax.Hub.Queue(['Typeset', MathJax.Hub, view]);
    });
  }

});
