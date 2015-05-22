import Ember from 'ember';

export default Ember.View.extend({
  classNames: ['figures-overlay'],
  toolbar: null,

  propagateToolbar: function() {
    this.set('controller.toolbar', this.get('toolbar'));
  }.observes('toolbar'),

  showOverlay: function() {
    $('body').addClass('modal-open');
  }.on('didInsertElement'),

  hideOverlay: function() {
    $('body').removeClass('modal-open');
  }.on('willDestroyElement')
});
