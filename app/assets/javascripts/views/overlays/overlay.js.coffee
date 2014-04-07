ETahi.OverlayView = Em.View.extend
  animateIn: (->
    Ember.run.scheduleOnce('afterRender', this, ETahi.animateOverlayIn);
  ).on('didInsertElement')

  stopBodyScrolling: (->
    $('html').addClass('noscroll')
  ).on('didInsertElement')

  allowBodyScrolling: (->
    $('html').removeClass('noscroll')
  ).on('willDestroyElement')
