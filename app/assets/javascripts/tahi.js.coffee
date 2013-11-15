window.Tahi ||= {}

Tahi.init = ->
  for form in $("form.js-submit-on-change[data-remote='true']")
    @setupSubmitOnChange $(form), $('select, input[type="checkbox"]', form)

Tahi.setupSubmitOnChange = (form, elements)->
  elements.on 'change', (e)->
    form.trigger 'submit.rails'
