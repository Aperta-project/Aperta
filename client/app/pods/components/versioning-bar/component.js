import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

export default Ember.Component.extend({
  oldText: null,
  currentBody: null,

  showVersion() {
    let version = this.get('selectedVersion');
    if (version) {
      RESTless.get('/api/versioned_texts/' + version.id).then((response) => {
        this.set('paper.currentVersionBody',
                 response['versioned_text']['text']);
      });
    }
  },

  setupObserver: function() {
    this.addObserver('selectedVersion', this, 'showVersion');
  }.on('didInsertElement'),

  setInitialVersion: function() {
    this.set('selectedVersion', this.get('paper.versions').slice(-1).pop());
  }.on('init')
});
