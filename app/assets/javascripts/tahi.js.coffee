window.Tahi ||= {}

Tahi.init = ->
  for form in $("form.js-submit-on-change[data-remote='true']")
    @setupSubmitOnChange $(form), $('select', form)

Tahi.setupSubmitOnChange = (form, elements)->
  elements.on 'change', (e)->
    form.trigger 'submit.rails'
