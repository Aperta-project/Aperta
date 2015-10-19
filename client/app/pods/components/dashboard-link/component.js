import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'tr',

  unreadCommentsCount: Ember.computed('model.commentLooks.[]', function() {
    return this.get('model.commentLooks.length');
  }),

  badgeTitle: Ember.computed('unreadCommentsCount', function() {
    return this.get('unreadCommentsCount') + ' new posts';
  }),

  status: Ember.computed('model.publishingState', function() {
    if (this.get('model.publishingState') == 'unsubmitted') {
      return 'DRAFT'
    } else {
      return this.get('model.publishingState').toUpperCase();
    };
  }),

  roles: Ember.computed('model.roles', function() {
    if (this.get('model.roles').indexOf('My Paper') > -1) {
      return 'Author'
    } else {
      return this.get('model.roles')
    }
  }),

  refreshTooltips() {
    Ember.run.scheduleOnce('afterRender', this, ()=> {
      if(this.$()) {
        this.$('.link-tooltip')
            .tooltip('destroy')
            .tooltip({placement: 'bottom'});
      }
    });
  },

  setupTooltips: Ember.on('didInsertElement', function() {
    this.addObserver('model.unreadCommentsCount', this, this.refreshTooltips);
    this.refreshTooltips();
  }),

  teardownTooltips: Ember.on('willDestroyElement', function() {
    this.removeObserver(
      'model.unreadCommentsCount',
      this,
      this.refreshTooltips
    );
  })
});
