import Ember from 'ember';
import RedirectsIfEditable from 'tahi/mixins/views/redirects-if-editable';

const { observer, on } = Ember;

export default Ember.View.extend(RedirectsIfEditable, {
  subNavVisible: false,
  downloadsVisible: false,
  contributorsVisible: false,

  applyManuscriptCss: on('didInsertElement', function() {
    $('#paper-body').attr('style', this.get('controller.model.journal.manuscriptCss'));
  }),

  setBackgroundColor: on('didInsertElement', function() {
    $('html').addClass('matte paper-submitted');
  }),

  resetBackgroundColor: on('willDestroyElement', function() {
    $('html').removeClass('matte paper-submitted');
  }),

  subNavVisibleDidChange: observer('subNavVisible', function() {
    if (this.get('subNavVisible')) {
      $('html').addClass('control-bar-sub-nav-active');
    } else {
      $('html').removeClass('control-bar-sub-nav-active');
    }
  }),

  teardownControlBarSubNav: on('willDestroyElement', function() {
    $('html').removeClass('control-bar-sub-nav-active');
  }),

  actions: {
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
