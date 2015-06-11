import Ember from 'ember';

export default Ember.Mixin.create({
  _setupGrowingTextarea: Ember.on('didInsertElement', function() {
    Ember.run.scheduleOnce('afterRender', this, function() {
      this.$('.inset-form-control-textarea').on('input', function() {
        this.style.height = '';
        this.style.height = Math.min(this.scrollHeight, 300) + 'px';
      }).trigger('input');
    });
  }),

  _teardownGrowingTextarea: Ember.on('willDestroyElement', function() {
    this.$('.inset-form-control-textarea').off();
  })
});
