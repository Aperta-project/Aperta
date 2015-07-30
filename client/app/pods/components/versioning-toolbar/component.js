import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Component.extend({
  oldText: null,
  currentBody: null,

  showVersion() {
    let version = this.get("selectedVersion");
    if (version) {
      RESTless.get("/api/versioned_texts/" + version.id).then((response) => {
        this.set("paper.currentVersionBody", response.versioned_text.text);
      });
    }
  },

  setupObserver: function() {
    this.addObserver('selectedVersion', this, "showVersion");
  }.on('didInsertElement'),

  versioningModeTransition: Ember.computed.or('transitioning', 'versioningMode'),

  actions: {
    openVersioningMode() {
      this.set('transitioning', true);

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
