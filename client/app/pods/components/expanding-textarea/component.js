import Ember from 'ember';

export default Ember.Component.extend({
  _setupGrowingTextarea: Ember.on('didInsertElement', function() {
    Ember.run.scheduleOnce('afterRender', this, function() {
      this.$('textarea').on('input', function() {
        this.style.height = '';
        this.style.height = Math.min(this.scrollHeight, 300) + 'px';
      }).trigger('input');
    });
  }),

  _teardownGrowingTextarea: Ember.on('willDestroyElement', function() {
    this.$('textarea').off();
  })
});
