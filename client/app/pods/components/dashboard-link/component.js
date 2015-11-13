import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'tr',
  unreadCommentsCount: Ember.computed.alias('model.commentLooks.length'),

  status: Ember.computed('model.publishingState', function() {
    if (this.get('model.publishingState') === 'unsubmitted') {
      return 'DRAFT';
    } else {
      return this.get('model.publishingState').toUpperCase();
    }
  }),

  roles: Ember.computed('model.roles', function() {
    if (this.get('model.roles').indexOf('My Paper') > -1) {
      return 'Author';
    } else {
      return this.get('model.roles');
    }
  }),

  refreshTooltips() {
    Ember.run.scheduleOnce('afterRender', this, () => {
      if(this.$()) {
        this.$('.link-tooltip')
            .tooltip('destroy')
            .tooltip({placement: 'bottom'});
      }
    });
  },

  setupTooltips: Ember.on('didInsertElement', function() {
    this.refreshTooltips();
    this.addObserver('unreadCommentsCount', this, this.refreshTooltips);
  }),

  teardownTooltips: Ember.on('willDestroyElement', function() {
    this.removeObserver('unreadCommentsCount', this, this.refreshTooltips);
  })
});
