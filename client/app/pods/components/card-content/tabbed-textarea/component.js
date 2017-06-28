import Ember from 'ember';

export default Ember.Component.extend({

  annotation: null,
  instructionText: null,

  _tabbedTextAreaSetup: Ember.on('didInsertElement', function() {
    // activate bootstrap nav tab elements
    this.$('.nav-tabs .active').tab('show');
  })

});
