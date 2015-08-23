import Ember from 'ember';

export default Ember.Component.extend({
  restless: Ember.inject.service('restless'),
  oldText: null,
  currentBody: null,

  showVersion() {
    let version = this.get('selectedVersion');
    if (version) {
      this.get('restless').get('/api/versioned_texts/' + version.id).then((response) => {
        this.set('paper.currentVersionBody',
                 response['versioned_text']['text']);
      });
    }
  },

  setupObserver: function() {
    this.addObserver('selectedVersion', this, 'showVersion');
  }.on('didInsertElement'),

  setInitialVersion: function() {
    this.set('selectedVersion', this.get('paper.versions.lastObject'));
  }.on('init')
});
