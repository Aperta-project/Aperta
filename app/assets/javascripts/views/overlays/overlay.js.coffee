ETahi.OverlayView = Em.View.extend
  animateIn: (->
    Ember.run.scheduleOnce('afterRender', this, ETahi.animateOverlayIn);
  ).on('didInsertElement')
