import Ember from 'ember';

export default Ember.View.extend({
  _setupGrowingTextarea: function() {
    Ember.run.scheduleOnce('afterRender', this, function() {
      this.$('.inset-form-control-textarea').on('input', function() {
        this.style.height = '';
        this.style.height = Math.min(this.scrollHeight, 300) + 'px';
      }).trigger('input');
    });
  }.on('didInsertElement'),

  _teardownGrowingTextarea: function() {
    this.$('.inset-form-control-textarea').off();
  }.on('willDestroyElement')
});
