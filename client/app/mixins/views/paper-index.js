import Ember from 'ember';
import RedirectsIfEditable from 'tahi/mixins/views/redirects-if-editable';

const { on } = Ember;

export default Ember.Mixin.create(RedirectsIfEditable, {
  classNames: ['edit-paper'],

  setBackgroundColor: on('didInsertElement', function() {
    $('html').addClass('matte');
  }),

  resetBackgroundColor: on('willDestroyElement', function() {
    $('html').removeClass('matte');
  }),

  _applyManuscriptCss: on('didInsertElement', function() {
    Ember.run.scheduleOnce('afterRender', ()=> {
      this.get('controller.model.journal').then(function(journal) {
        Ember.$('#paper-body').attr('style', journal.get('manuscriptCss'));
      });
    });
  }),

  teardownControlBarSubNav: on('willDestroyElement', function() {
    $('html').removeClass('control-bar--sub-item-active');
  })
});
