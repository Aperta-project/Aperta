import Ember from 'ember';
import RedirectsIfEditable from 'tahi/mixins/views/redirects-if-editable';

let on = Ember.on;

export default Ember.Mixin.create(RedirectsIfEditable, {
  classNames: ['edit-paper'],
  editor: null,
  locked: Ember.computed.alias('controller.locked'),
  isEditing: Ember.computed.alias('controller.isEditing'),
  subNavVisible: false,
  downloadsVisible: false,
  contributorsVisible: false,
  versionsVisible: false,

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

  subNavVisibleDidChange: Ember.observer('subNavVisible', function() {
    if (this.get('subNavVisible')) {
      $('.paper-toolbar').css('top', '103px');
      $('html').addClass('control-bar-sub-nav-active');
    } else {
      $('.paper-toolbar').css('top', '60px');
      $('html').removeClass('control-bar-sub-nav-active');
    }
  }),

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
      this.set('subNavVisible', false);
      this.send('hideVisible');
    },

    hideVisible() {
      this.setProperties({
        contributorsVisible: false,
        downloadsVisible: false,
        versionsVisible: false
      });
    },

    showContributors() {
      this.send('hideVisible');
      this.set('contributorsVisible', true);
    },

    showDownloads() {
      this.send('hideVisible');
      this.set('downloadsVisible', true);
    },

    showVersions() {
      this.send('hideVisible');
      this.set('versionsVisible', true);
    },

    toggleVersioningMode() {
      this.toggleProperty('controller.model.versioningMode');
      this.send('showSubNav', 'versions');
    }
  }
});
