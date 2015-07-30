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

  versioningModeTransition: Ember.computed.or('transitioning', 'versioningMode'),

  actions: {
    openVersioningMode() {
      this.set('transitioning', true);

      Ember.run.later(()=>{
        this.set('versioningMode', true);
        this.set('transitioning', false);
      }, 500);

      this.addObserver('selectedVersion', this, "showVersion");
      this.set('selectedVersion', this.get('paper.versions')[0]);
      this.showVersion();
    },

    closeVersioningMode() {
      this.set('versioningMode', false);
      this.removeObserver('selectedVersion', this, "showVersion");
    }
  }
});
