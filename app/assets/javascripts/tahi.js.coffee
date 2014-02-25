window.Tahi ||= {}

Tahi.init = ->
  # Tahi.papers.init()
  # Tahi.overlay.init()
  # Tahi.flowManager.init()
  # Tahi.manuscriptManager.init(location.href)
  Tahi.overlays.newCard.init()
  for i of Tahi
    (Tahi[i].init||->).call(Tahi[i])

  for form in $("form.js-submit-on-change[data-remote='true']")
    @setupSubmitOnChange $(form), $('select, input[type="radio"], input[type="checkbox"], textarea', form)

  for element in $('[data-overlay-name]')
    Tahi.initOverlay(element)

  Tahi.initSpinner()
  Tahi.bindSpinnerEvents()

Tahi.initSpinner = ->
  opts =
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
    top: "40px" # Top position relative to parent in px
    left: "20px" # Left position relative to parent in px

  spinner = new Spinner(opts).spin($('#spinner')[0])
  $('#spinner').append(spinner)

Tahi.startSpinner = ->
  $('#spinner').show()

Tahi.stopSpinner = ->
  $('#spinner').hide()

Tahi.bindSpinnerEvents = ->
  document.addEventListener "page:fetch", Tahi.startSpinner
  document.addEventListener "page:receive", Tahi.stopSpinner

  $.ajaxSetup
    beforeSend: Tahi.startSpinner
    complete: Tahi.stopSpinner
    success: Tahi.stopSpinner


Tahi.className = (obj) ->
  _.reduce(obj,((memo, val, key) -> if val then "#{memo} #{key}" else memo), "").trim()

Tahi.setupSubmitOnChange = (form, elements, options) ->
  form.on 'ajax:success', options?.success
  elements.off 'change'
  elements.on 'change', (e) ->
    form.trigger 'submit.rails'

