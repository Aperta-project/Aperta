`import Ember from 'ember'`
`import AnimateOverlay from 'tahi/mixins/animate-overlay'`

OverlayView = Ember.View.extend AnimateOverlay,
  animateIn: (->
    Ember.run.scheduleOnce('afterRender', this, @animateOverlayIn)
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

`export default OverlayView`
