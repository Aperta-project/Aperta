`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`

moduleFor('controller:admin/journal/flow-manager', 'Unit: controller/journalFlowManager')

test 'newFlowPosition puts the new flow at the highest position', (assert) ->
  eo = Ember.Object
  flows = [
    eo.create(position: 1)
    eo.create(position: 2)
  ]
  oldRole = eo.create(flows: flows)
  controller = @subject()
  controller.set 'model', oldRole

  assert.equal controller.newFlowPosition(), 3
