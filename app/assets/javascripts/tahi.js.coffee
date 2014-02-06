window.Tahi ||= {}

Tahi.init = ->
  Tahi.papers.init()
  Tahi.overlays.authors.init()
  Tahi.overlays.figure.init()
  Tahi.overlays.newCard.init()
  Tahi.overlays.declaration.init()
  Tahi.overlays.registerDecision.init()
  Tahi.overlays.uploadManuscript.init()
  Tahi.overlays.techCheck.init()
  Tahi.overlays.reviewerReport.init()
  Tahi.overlays.paperEditor.init()
  Tahi.overlays.paperReviewer.init()
  Tahi.overlays.paperAdmin.init()
  Tahi.overlays.task.init()

  for form in $("form.js-submit-on-change[data-remote='true']")
    @setupSubmitOnChange $(form), $('select, input[type="radio"], input[type="checkbox"], textarea', form)

  for element in $('[data-overlay-name]')
    Tahi.initOverlay(element)

  Tahi.initChosen()
  Tahi.escapeKeyClosesOverlay()

Tahi.escapeKeyClosesOverlay = ->
  $('body').on 'keyup', (e) ->
    if e.which == 27
      $('.close-overlay').click()

Tahi.initChosen = ->
  $('.chosen-select').chosen
    width: '200px'

Tahi.setupSubmitOnChange = (form, elements, options) ->
  form.on 'ajax:success', options?.success
  elements.on 'change', (e) ->
    form.trigger 'submit.rails'
