`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`

moduleFor('controller:overlays/invitations', 'InvitationsOverlayController')

test 'closes the overlay after all invitations have been addressed', ->
  expect(1)
  model = [1,2,3]
  fakeTarget = send: (arg) ->
    ok(true, 'Called closeOverlay') if arg == "closeOverlay"
  controller = @subject(model: model, target: fakeTarget)
  controller.set('model', [])
