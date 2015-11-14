import Ember from 'ember';
import RedirectsIfEditable from 'tahi/mixins/views/redirects-if-editable';

let on = Ember.on;

export default Ember.Mixin.create(RedirectsIfEditable, {
  classNames: ['edit-paper'],

  setBackgroundColor: on('didInsertElement', function() {
    $('html').addClass('matte');
  }),

  resetBackgroundColor: on('willDestroyElement', function() {
    $('html').removeClass('matte');
  }),

  applyManuscriptCss: Ember.observer(
    'controller.model.journal.manuscriptCss',
    function() {
      const style = this.get('controller.model.journal.manuscriptCss');
      $('#paper-body').attr('style', style);
    }),

  teardownControlBarSubNav: on('willDestroyElement', function() {
    $('html').removeClass('control-bar--sub-item-active');
  })
});
