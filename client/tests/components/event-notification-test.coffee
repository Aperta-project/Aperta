`import Ember from 'ember'`
`import { test, moduleForComponent } from 'ember-qunit'`

moduleForComponent 'event-notification', 'Unit: components/event-notification'

test '#hasNotification returns false if no events exist', ->
  fakeNotificationManager = Ember.Object.create(currentEvent: [])
  component = @subject(notificationManager: fakeNotificationManager)
  ok !component.get('shouldDisplayNotification')

test '#hasNotification returns true if events exist', ->
  event = Ember.Object.create(eventName: "Some Event")
  fakeNotificationManager = Ember.Object.create(currentEvent: event)
  component = @subject(notificationManager: fakeNotificationManager)
  ok component.get('shouldDisplayNotification')
