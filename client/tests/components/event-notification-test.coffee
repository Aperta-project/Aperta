`import Ember from 'ember'`
`import { test, moduleForComponent } from 'ember-qunit'`

moduleForComponent 'event-notification', 'Unit: components/event-notification'

test '#hasNotification returns false if no events exist', ->
  fakeNotificationManager = Ember.Object.create(events: [])
  component = @subject(notificationManager: fakeNotificationManager)
  ok !component.get('hasNotification')

test '#hasNotification returns true if events exist', ->
  event = Ember.Object.create(name: "Some Event", actor: { user: 1 }, target: { paper: 201 })
  fakeNotificationManager = Ember.Object.create(events: [event])
  component = @subject(notificationManager: fakeNotificationManager)
  ok component.get('hasNotification')
