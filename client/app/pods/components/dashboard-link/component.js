import Ember from 'ember';

export default Ember.Component.extend({
  unreadCommentsCount: function() {
    return this.get('model.commentLooks.length');
  }.property('model.commentLooks.@each'),

  badgeTitle: function() {
    return this.get('unreadCommentsCount') + ' new posts';
  }.property('unreadCommentsCount'),

  refreshTooltips() {
    Ember.run.scheduleOnce('afterRender', this, ()=> {
      if(this.$()) {
        this.$('.link-tooltip')
            .tooltip('destroy')
            .tooltip({placement: 'bottom'});
      }
    });
  },

  setupTooltips: (function() {
    this.addObserver('model.unreadCommentsCount', this, this.refreshTooltips);
    this.refreshTooltips();
  }).on('didInsertElement'),

  teardownTooltips: function() {
    this.removeObserver(
      'model.unreadCommentsCount',
      this,
      this.refreshTooltips
    );
  }.on('willDestroyElement')
});
