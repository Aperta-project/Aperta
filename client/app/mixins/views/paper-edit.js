import Ember from 'ember';
import RedirectsIfEditable from 'tahi/mixins/views/redirects-if-editable';

let on = Ember.on;

export default Ember.Mixin.create(RedirectsIfEditable, {
  classNames: ['edit-paper'],
  editor: null,
  locked: Ember.computed.alias('controller.locked'),
  isEditing: Ember.computed.alias('controller.isEditing'),

  setBackgroundColor: on('didInsertElement', function() {
    $('html').addClass('matte');
  }),

  resetBackgroundColor: on('willDestroyElement', function() {
    $('html').removeClass('matte');
  }),

  applyManuscriptCss: on('didInsertElement', function() {
    $('#paper-body').attr('style', this.get('controller.model.journal.manuscriptCss'));
  }),

  teardownControlBarSubNav: on('willDestroyElement', function() {
    $('html').removeClass('control-bar-sub-nav-active');
  }),

  saveTitleChanges: on('willDestroyElement', function() {
    this.timeoutSave();
  }),

  actions: {
    submit() {
      this.saveEditorChanges();
      this.get('controller').send('confirmSubmitPaper');
    },

    withdrawManuscript() {
      this.get('controller').send('showConfirmWithdrawOverlay');
    }
  }
});
