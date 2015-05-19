`import Ember from 'ember'`

AnimateElement = Ember.Mixin.create
  out: (selector, speed) ->
    defer = new Ember.RSVP.defer()
    $(selector).hide()

    Ember.run.later defer, (->
      defer.resolve()
      return
    ), speed

    defer.promise

  in: (selector, speed) ->
    defer = new Ember.RSVP.defer()
    $(selector).show()

    Ember.run.later defer, (->
      defer.resolve()
      return
    ), speed

    defer.promise

  animateOverlayIn:  (selector='#overlay')-> @in selector, 150
  animateOverlayOut: (selector='#overlay')-> @out selector, 150

`export default AnimateElement`
