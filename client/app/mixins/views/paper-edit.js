import Ember from 'ember';
import RedirectsIfEditable from 'tahi/mixins/views/redirects-if-editable';

export default Ember.Mixin.create(RedirectsIfEditable, {
  classNames: ['edit-paper'],
  editor: null,
  locked: Ember.computed.alias('controller.locked'),
  isEditing: Ember.computed.alias('controller.isEditing'),
  subNavVisible: false,
  downloadsVisible: false,
  contributorsVisible: false,

  setBackgroundColor: function() {
    $('html').addClass('matte');
  }.on('didInsertElement'),

  resetBackgroundColor: function() {
    return $('html').removeClass('matte');
  }.on('willDestroyElement'),

  applyManuscriptCss: function() {
    $('#paper-body').attr('style', this.get('controller.model.journal.manuscriptCss'));
  }.on('didInsertElement'),

  subNavVisibleDidChange: function() {
    if (this.get('subNavVisible')) {
      $('.paper-toolbar').css('top', '103px');
      $('html').addClass('control-bar-sub-nav-active');
    } else {
      $('.paper-toolbar').css('top', '60px');
      $('html').removeClass('control-bar-sub-nav-active');
    }
  }.observes('subNavVisible'),

  teardownControlBarSubNav: function() {
    $('html').removeClass('control-bar-sub-nav-active');
  }.on('willDestroyElement'),

  saveTitleChanges: function() {
    this.timeoutSave();
  }.on('willDestroyElement'),

  actions: {
    submit() {
      this.saveEditorChanges();
      this.get('controller').send('confirmSubmitPaper');
    },

    showSubNav(sectionName) {
      if (this.get('subNavVisible') && this.get(sectionName + 'Visible')) {
        this.send('hideSubNav');
      } else {
        this.set('subNavVisible', true);
        this.send('show' + (sectionName.capitalize()));
      }
    },

    hideSubNav() {
      this.setProperties({
        subNavVisible: false,
        contributorsVisible: false,
        downloadsVisible: false
      });
    },

    showContributors() {
      this.set('contributorsVisible', true);
      this.set('downloadsVisible', false);
    },

    showDownloads() {
      this.set('contributorsVisible', false);
      this.set('downloadsVisible', true);
    }
  }
});
