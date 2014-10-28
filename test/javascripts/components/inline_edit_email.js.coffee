moduleForComponent 'inline-edit-email', 'Unit: components/inline-edit-email',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp()

test '#sendEmail', ->
  component = @subject()
  component.send 'sendEmail'
  ok component.get('bodyPart')
