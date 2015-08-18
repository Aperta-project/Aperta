import Ember from 'ember';
import PaperBaseMixin from 'tahi/mixins/controllers/paper-base';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';
import LazyLoader from 'ember-cli-lazyloader/lib/lazy-loader';
import ENV from 'tahi/config/environment';

export default Ember.Controller.extend(PaperBaseMixin, DiscussionsRoutePathsMixin, {
  subRouteName: 'index',

  queryParams: ['showVersions'],
  showVersions: null,

  // MATHJAX (for rendering equations).
  renderEquations: true,

  loadScripts: function() {
    console.log("hellp");
    if (this.renderEquations) {
      LazyLoader.loadScripts([ENV['tahi-editor-ve']['mathJaxUrl']]);
      this.addObserver('model.versioningMode', this, 'refreshEquations');
      this.refreshEquations();
    }
  }.on('init'),


  refreshEquations: function() {
    Ember.run.next(() => {
      MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
    });
  }
});
