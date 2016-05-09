import Ember from 'ember';
import ENV from 'tahi/config/environment';

export default Ember.Controller.extend({
  can: Ember.inject.service('can'),
  delayedSave: false,
  isLoading: false,
  isLoggedIn: Ember.computed.notEmpty('currentUser'),
  canViewAdminLinks: false,
  showOverlay: false,
  showFeedbackOverlay: false,
  journals: null,
  canViewPaperTracker: false,

  setCanViewPaperTracker: function() {
    if (this.journals === null) {
      return false;
    }
    var that = this;
    this.journals.toArray().forEach(function(journal) {
      that.get('can').can('view_paper_tracker', journal).then( (value) =>
        Ember.run(function() {
          if (value) {
            that.set('canViewPaperTracker', true);
          }
        })
      );
    });
  },

  clearError: Ember.observer('currentPath', function() {
    this.set('error', null);
  }),

  resetScrollPosition: Ember.observer('currentPath', function() {
    window.scrollTo(0, 0);
  }),

  testing: Ember.computed(function() {
    return Ember.testing || ENV.environment === 'test';
  }),

  showSaveStatusDiv: Ember.computed.and('testing', 'delayedSave'),

  specifiedAppName: window.appName,

  init: function() {
    var that = this;
    this.store.find('journal').then( (journals)=> {
      that.set('journals', journals);
      that.setCanViewPaperTracker();
    });
  },

  actions: {
    showFeedbackOverlay() { this.set('showFeedbackOverlay', true); },
    hideFeedbackOverlay() { this.set('showFeedbackOverlay', false); }
  }
});
