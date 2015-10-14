import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'tr',

  unreadCommentsCount: Ember.computed('model.commentLooks.[]', function() {
    return this.get('model.commentLooks.length');
  }),

  badgeTitle: Ember.computed('unreadCommentsCount', function() {
    return this.get('unreadCommentsCount') + ' new posts';
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
