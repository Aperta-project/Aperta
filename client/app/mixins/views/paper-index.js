import Ember from 'ember';

export default Ember.Mixin.create({
  classNames: ['edit-paper'],
  editor: null,

  setBackgroundColor: Ember.on('didInsertElement', function() {
    $('html').addClass('matte');
  }),

  resetBackgroundColor: Ember.on('willDestroyElement', function() {
    $('html').removeClass('matte');
  }),

  applyManuscriptCss: Ember.observer(
    'controller.model.journal.manuscriptCss',
    function() {
      let style = this.get('controller.model.journal.manuscriptCss');
      $('#paper-body').attr('style', style);
    }
  ),

  teardownControlBarSubNav: Ember.on('willDestroyElement', function() {
    $('html').removeClass('control-bar-sub-nav-active');
  })
});
