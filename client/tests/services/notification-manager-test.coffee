`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`

moduleFor('service:notification-manager', 'Unit: services/notification-manager')

test "#reset nulls out the currentEvent property", ->
  eventObject = Ember.Object.create(eventName: "paper.exploded")
  service = @subject(currentEvent: eventObject)
  service.reset()
  deepEqual(service.get('currentEvent'), null)

test "#dismiss destroys the currentEvent and calls reset action", ->
  eventObject = Ember.Object.create(eventName: "paper.exploded", destroyRecord: -> ok(true, "record destroyed"))
  service = @subject(currentEvent: eventObject, reset: -> ok(true, "Calls reset"))
  service.dismiss()

test "#notify will set currentEvent with the event passed in unless already set", ->
  eventObject = Ember.Object.create(eventName: "paper.exploded")
  service = @subject()
  service.notify(eventObject)
  deepEqual(service.get('currentEvent'), eventObject)

test "#notify will not set currentEvent with the event passed in if already set", ->
  newEventObject = Ember.Object.create(eventName: "paper.exploded")
  existingEventObject = Ember.Object.create(eventName: "paper.created")
  service = @subject(currentEvent: existingEventObject)
  service.notify(newEventObject)
  deepEqual(service.get('currentEvent'), existingEventObject)
