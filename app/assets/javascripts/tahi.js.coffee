window.Tahi ||= {}

Tahi.init = ->
  Tahi.papers.init()
  Tahi.overlays.authors.init()

  for form in $("form.js-submit-on-change[data-remote='true']")
    @setupSubmitOnChange $(form), $('select, input[type="checkbox"]', form)

  for element in $('[data-overlay-name]')
    Tahi.initOverlay(element)

Tahi.setupSubmitOnChange = (form, elements) ->
  elements.on 'change', (e) ->
    form.trigger 'submit.rails'

Tahi.displayOverlay = (element) ->
  overlay = $('#overlay')
  overlayName = $(element).data('overlay-name')
  contentContainer = $("##{overlayName}-content")
  container = $('main', overlay)
  contentContainer.children().appendTo(container)

  handler = (e) ->
    e.preventDefault()
    container.children().appendTo(contentContainer)
    overlay.hide()
    $('.close-overlay').unbind('click', handler)

  $('.close-overlay', overlay).on 'click', handler

  overlay.show()

Tahi.initOverlay = (element) ->
  $(element).on 'click', (e) ->
    e.preventDefault()
    Tahi.displayOverlay element
