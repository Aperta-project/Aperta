import Ember from 'ember';

export default Ember.View.extend({
  locked: Ember.computed.alias('controller.locked'),
  isEditing: Ember.computed.alias('controller.isEditing'),

  subNavVisible: false,
  downloadsVisible: false,
  contributorsVisible: false,

  propagateToolbar: function() {
    this.set('controller.toolbar', this.get('toolbar'));
  }.observes('toolbar'),

  setBackgroundColor: function() {
    $('html').addClass('matte');
  }.on('didInsertElement'),

  resetBackgroundColor: function() {
    $('html').removeClass('matte');
  }.on('willDestroyElement'),

  subNavVisibleDidChange: function() {
    if(this.get('subNavVisible')) {
      $('.editor-toolbar').css('top', '103px');
      $('html').addClass('control-bar-sub-nav-active');
    } else {
      $('.editor-toolbar').css('top', '60px');
      $('html').removeClass('control-bar-sub-nav-active');
    }
  }.observes('subNavVisible'),

  actions: {
    showSubNav: function (sectionName) {
      if(this.get('subNavVisible') && this.get(sectionName + 'Visible')) {
        this.send('hideSubNav');
      } else {
        this.set('subNavVisible', true);
        this.send('show' + sectionName.capitalize());
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
