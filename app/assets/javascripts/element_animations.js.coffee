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

  opts:( ->
    lines: 7 # The number of lines to draw
    length: 0 # The length of each line
    width: 7 # The line thickness
    radius: 7 # The radius of the inner circle
    corners: 1 # Corner roundness (0..1)
    rotate: 0 # The rotation offset
    direction: 1 # 1: clockwise, -1: counterclockwise
    color: "#8ecb87" # #rgb or #rrggbb or array of colors
    speed: 1.3 # Rounds per second
    trail: 68 # Afterglow percentage
    shadow: false # Whether to render a shadow
    hwaccel: false # Whether to use hardware acceleration
    className: "spinner" # The CSS class to assign to the spinner
    zIndex: 2e9 # The z-index (defaults to 2000000000)
  ).property()

  spinner: null

  start: ( ->
    options = @get('opts')
    if $("#top-nav").length
      spinner = new Spinner(options).spin()
      $("#top-nav").append(spinner.el)
    else
      options = Ember.merge(options, {className: 'body-spinner', lines: 20, radius: 30})
      spinner = new Spinner(options).spin()
      $("body").append(spinner.el)
    @set('spinner', spinner)
  ).on('init')

  stop: ( ->
    @get('spinner').stop()
  )

