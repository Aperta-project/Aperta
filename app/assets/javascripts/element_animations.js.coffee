ETahi.animateElement =
  out: (selector, speed) ->
    defer = new Em.RSVP.defer()
    $(selector).removeClass('in').addClass('out')

    Em.run.later defer, (->
      defer.resolve()
      return
    ), speed

    defer.promise

  in: (selector, speed) ->
    defer = new Em.RSVP.defer()
    $(selector).addClass('in')

    Em.run.later defer, (->
      defer.resolve()
      return
    ), speed

    defer.promise

ETahi.animateOverlayIn = ->
  ETahi.animateElement.in '.overlay', 530

ETahi.animateOverlayOut = ->
  ETahi.animateElement.out '.overlay', 230
