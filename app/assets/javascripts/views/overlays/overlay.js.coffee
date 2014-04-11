ETahi.OverlayView = Em.View.extend
  animateIn: (->
    Ember.run.scheduleOnce('afterRender', this, ETahi.animateOverlayIn);
  ).on('didInsertElement')

  allowBodyScrolling: (->
    $('html').removeClass('noscroll')
  ).on('willDestroyElement')

  stopBodyScrolling: (->
    $('html').addClass('noscroll')
  ).on('didInsertElement')

  setupKeyup: (->
    $('body').on 'keyup.overlay', (e) =>
      if e.keyCode == 27 || e.which == 27
        if $(e.target).is(':not(input, textarea)')
          @get('controller').send('closeAction')
  ).on('didInsertElement')

  tearDownKeyup: (->
    $('body').off('keyup.overlay')
  ).on('willDestroyElement')
