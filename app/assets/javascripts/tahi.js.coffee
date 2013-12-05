window.Tahi ||= {}

Tahi.init = ->
  Tahi.papers.init()
  Tahi.overlays.authors.init()
  Tahi.overlays.figures.init()

  for form in $("form.js-submit-on-change[data-remote='true']")
    @setupSubmitOnChange $(form), $('select, input[type="checkbox"], textarea', form)

  for element in $('[data-overlay-name]')
    Tahi.initOverlay(element)

Tahi.setupSubmitOnChange = (form, elements) ->
  elements.on 'change', (e) ->
    form.trigger 'submit.rails'

Tahi.displayOverlay = (element) ->
  overlay = $('#overlay')

  $element = $(element)
  overlayName = $element.data('overlay-name')
  overlayTitle = $element.data('overlay-title')

  titleContainer = $('header h2', overlay)
  titleContainer.text overlayTitle

  contentContainer = $("##{overlayName}-content")
  container = $('main', overlay)
  contentContainer.children().appendTo(container)

  handler = (e) ->
    e.preventDefault()
    container.children().appendTo(contentContainer)
    overlay.hide()
    titleContainer.empty()
    $('.close-overlay').unbind('click', handler)

  $('.close-overlay', overlay).on 'click', handler

  overlay.show()

Tahi.initOverlay = (element) ->
  $(element).on 'click', (e) ->
    e.preventDefault()
    Tahi.displayOverlay element
