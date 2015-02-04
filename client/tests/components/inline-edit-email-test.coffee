`import Ember from 'ember'`
`import { test, moduleForComponent } from 'ember-qunit'`

moduleForComponent 'inline-edit-email', 'Unit: components/inline-edit-email'

test '#sendEmail', ->
  targetObject =
    emailMock: (data) ->
      ok true, 'sends the sendEmail action to its target'
      ok data.subject == "Greetings!", "contains the subject"
      ok data.body == "Welcome to Vulcan!", "contains the body"

  mockParent =
    send: (arg) ->
      ok arg == 'save', "sends save to the parentView"
    emailSentStates: Ember.ArrayProxy.create(content: [])

  component = @subject()
  component.setProperties
    sendEmail: 'emailMock'
    bodyPart: {subject: "Greetings!", value: "Welcome to Vulcan!"}
    overlayParticipants: [Ember.Object.create(id: 5)]
    recipients: [Ember.Object.create(id: 5)]
    targetObject: targetObject
    parentView: mockParent
    showChooseReceivers: true

  component.send 'sendEmail'
  ok !component.get('showChooseReceivers'), 'turns off the receivers selector'
  ok component.get('emailSentStates').contains('Greetings!'), 'records itself as sent to the controller'

test 'shows itelf as sent based on emailSentStates', ->
  mockParent =
    send: (arg) ->
      ok arg == 'save', "sends save to the parentView"
    emailSentStates: Ember.ArrayProxy.create(content: ['Greetings!'])
  component = @subject()
  component.setProperties
    parentView: mockParent
    bodyPart: {subject: "Greetings!", value: "Welcome to Vulcan!"}
    overlayParticipants: [Ember.Object.create(id: 5)]
    recipients: [Ember.Object.create(id: 5)]
    showChooseReceivers: true

  ok component.get('showSentMessage'), 'It shows up when its key is in emailSentStates'
  component.send 'clearEmailSent'
  ok !component.get('showSentMessage'), "It doesn't show up after clearing"
