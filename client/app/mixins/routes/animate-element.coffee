`import Ember from 'ember'`

AnimateElement = Ember.Mixin.create
  fadeOut: (selector, speed) ->
    defer = new Ember.RSVP.defer()
    $(selector).removeClass('animation-fade-in').addClass('animation-fade-out')

    Ember.run.later defer, (->
      defer.resolve()
      return
    ), speed

    defer.promise

  fadeIn: (selector, speed) ->
    defer = new Ember.RSVP.defer()
    $(selector).addClass('animation-fade-in')

    Ember.run.later defer, (->
      defer.resolve()
      return
    ), speed

    defer.promise

  slideIn: (selector, speed) ->
    defer = new Ember.RSVP.defer()
    $(selector).addClass('animation-slide-in')

    Ember.run.later defer, (->
      defer.resolve()
      return
    ), speed

    defer.promise

  slideOut: (selector, speed) ->
    defer = new Ember.RSVP.defer()
    $(selector).addClass('animation-slide-out')

    Ember.run.later defer, (->
      defer.resolve()
      return
    ), speed

    defer.promise
    
  animateOverlayFadeIn: -> @fadeIn '.overlay', 330
  animateOverlayFadeOut: -> @fadeOut '.overlay', 230

  animateOverlaySlideIn: -> @slideIn '.overlay', 330
  animateOverlaySlideOut: -> @slideOut '.overlay', 230

`export default AnimateElement`
