import Ember from 'ember';

export default Ember.Component.extend({

  annotation: null,
  instructionText: null,

  didInsertElement() {
    this._super(...arguments);
    // activate bootstrap nav tab elements
    this.$('.nav-tabs > li:first-child').addClass('active');
    this.$('.tab-content > .tab-pane:first-child').addClass('active');
    this.$('.nav-tabs .active').tab('show');
  }

});
