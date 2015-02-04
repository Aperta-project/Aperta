`import Ember from 'ember'`

AnimateElement = Ember.Mixin.create
  out: (selector, speed) ->
    defer = new Ember.RSVP.defer()
    $(selector).removeClass('animation-fade-in').addClass('animation-fade-out')

    Ember.run.later defer, (->
      defer.resolve()
      return
    ), speed

    defer.promise

  in: (selector, speed) ->
    defer = new Ember.RSVP.defer()
    $(selector).addClass('animation-fade-in')

    Ember.run.later defer, (->
      defer.resolve()
      return
    ), speed

    defer.promise

  animateOverlayIn: -> @in '.overlay', 330
  animateOverlayOut: -> @out '.overlay', 230

`export default AnimateElement`
