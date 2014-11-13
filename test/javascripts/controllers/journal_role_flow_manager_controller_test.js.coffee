moduleFor('controller:journal-role-flow-manager', 'Unit: controller/journalRoleFlowManager')

test 'newFlowPosition puts the new flow at the highest position', ->
  eo = Ember.Object
  flows = [
    eo.create(position: 1)
    eo.create(position: 2)
  ]
  role = eo.create(flows: flows)
  controller = @subject()
  controller.set 'model', role

  equal controller.newFlowPosition(), 3
