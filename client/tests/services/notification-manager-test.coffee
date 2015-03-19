`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`

moduleFor('service:notification-manager', 'Unit: services/notifcation-manager')

test "#setup sets the actionNames property", ->
  someActions = ["some::action::name, other::action::name"]
  service = @subject()
  service.setup(someActions)
  equal(service.get('actionNames'), someActions)

test "#dismiss nulls out the actionNotification property", ->
  someAction = "some::action::name"
  service = @subject(actionNotification: someAction)
  service.reset()
  equal(service.get('actionNotification'), null)

test "#reset sets the actionNames to an empty array and calls dismiss action", ->
  someActions = ["some::action::name, other::action::name"]
  service = @subject(actionNames: someActions, dismiss: -> ok(true, "Calls dismiss"))
  service.reset()
  deepEqual(service.get('actionNames'), [])

test "#notify will return and do nothing when there is an actionNotifcation set", ->
  someAction = "some::action::name"
  service = @subject(actionNotification: someAction)
  equal(service.notify(), undefined)
