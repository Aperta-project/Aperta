module('Unit: components/flow-task-group')

test '#tasks returns tasks that belong to the litePaper', ->
  litePaper = Ember.Object.create(title: "Foo")
  litePaper2 = Ember.Object.create(title: "Bar")
  includedTask = Ember.Object.create(litePaper: litePaper)
  excludedTask = Ember.Object.create(litePaper: litePaper2)
  flow = Ember.Object.create(litePapers: [litePaper, litePaper2], tasks: [includedTask, excludedTask])

  component = ETahi.FlowTaskGroupComponent.create(flow: flow, litePaper: litePaper)

  ok component.get('tasks').contains(includedTask)
  ok !component.get('tasks').contains(excludedTask)
