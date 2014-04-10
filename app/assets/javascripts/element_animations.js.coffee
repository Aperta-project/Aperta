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
  ETahi.animateElement.in '.overlay', 330

ETahi.animateOverlayOut = ->
  ETahi.animateElement.out '.overlay', 230

ETahi.Spinner = Ember.Object.extend

  opts:
    lines: 9 # The number of lines to draw
    length: 0 # The length of each line
    width: 7 # The line thickness
    radius: 14 # The radius of the inner circle
    corners: 1 # Corner roundness (0..1)
    rotate: 0 # The rotation offset
    direction: 1 # 1: clockwise, -1: counterclockwise
    color: "#8ecb87" # #rgb or #rrggbb or array of colors
    speed: 1.1 # Rounds per second
    trail: 68 # Afterglow percentage
    shadow: false # Whether to render a shadow
    hwaccel: false # Whether to use hardware acceleration
    className: "spinner" # The CSS class to assign to the spinner
    zIndex: 2e9 # The z-index (defaults to 2000000000)

  spinner: null

  start: ( ->
    spinner =  new Spinner(@get('opts')).spin()
    @set('spinner', spinner)
    $("body").append(spinner.el)
  ).on('init')

  stop: ( ->
    @get('spinner').stop()
  )

