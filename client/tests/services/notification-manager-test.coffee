`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`

moduleFor('service:notification-manager', 'Unit: services/notifcation-manager')

test "#setup sets the actionNames property", ->
  someActions = ["some::action::name, other::action::name"]
  service = @subject()
  service.setup(someActions)
  deepEqual(service.get('actionNames'), someActions)

test "#dismiss nulls out the actionNotification property", ->
  someAction = "some::action::name"
  service = @subject(actionNotification: someAction)
  service.reset()
  deepEqual(service.get('actionNotification'), null)

test "#reset sets the actionNames to an empty array and calls dismiss action", ->
  someActions = ["some::action::name, other::action::name"]
  service = @subject(actionNames: someActions, dismiss: -> ok(true, "Calls dismiss"))
  service.reset()
  deepEqual(service.get('actionNames'), [])

test "#notify will return and do nothing when there is an actionNotifcation set", ->
  someAction = "some::action::name"
  service = @subject(actionNotification: someAction)
  deepEqual(service.notify("doesnt::matter"), undefined)

test "#notify will set the actionNotification property with the passed in action it finds", ->
  someAction = "some::action::name"
  someActions = ["another::action::name", someAction]
  service = @subject(actionNames: someActions)
  service.notify(someAction)
  deepEqual(service.get('actionNotification'), someAction)

test "the events property returns an empty array when the actionNotifcation property is null", ->
  service = @subject()
  deepEqual(service.get('events'), [])

test "the events property returns an array of events from the store filtered by their name", ->
  someAction = "some::action::name"
  eventObject = Ember.Object.create(name: someAction)
  fakeStore =
    all: (type) ->
      equal(type, 'event')
      [Ember.Object.create(name: "other::action::name"), eventObject]

  service = @subject(actionNotification: someAction, store: fakeStore)

  deepEqual(service.get('events'), [eventObject])
