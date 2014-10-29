moduleForComponent 'inline-edit-email', 'Unit: components/inline-edit-email',
  setup: ->
    setupApp()

test '#sendEmail', ->
  targetObject = 
    emailMock: (data) ->
      ok true, 'sends the sendEmail action to its target'
      ok data.subject == "Greetings!", "contains the subject"
      ok data.body == "Welcome to Vulcan!", "contains the body"

  mockParent = 
    send: (arg) ->
      ok arg == 'save', "sends save to the parentView"

  containerComponent = 
  component = @subject()
  component.set('sendEmail', 'emailMock')
  component.set('bodyPart', {subject: "Greetings!", value: "Welcome to Vulcan!"})
  component.setProperties
    overlayParticipants: [Ember.Object.create(id: 5)]
    recipients: [Ember.Object.create(id: 5)]
    targetObject: targetObject
    parentView: mockParent
    showChooseReceivers: true

  component.send 'sendEmail'
  ok component.get('emailSent')
  ok !component.get('showChooseReceivers')

