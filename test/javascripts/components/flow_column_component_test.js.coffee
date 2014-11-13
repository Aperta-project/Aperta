moduleForComponent 'flow-column', 'Unit: components/flow-column',
  needs: [
    'component:progress-spinner'
    'component:flow-task-group'
    'component:select-2-single'
  ]

appendBasicComponent = (context, attrs) ->
  Ember.run =>
    context.component = context.subject()
    context.component.setProperties(attrs)
  context.append()

test "clicking the X should send 'removeFlow'", ->
  targetObject =
    externalAction: (flow) ->
      ok true
  componentAttrs =
    removeFlow: 'externalAction'
    targetObject: targetObject
    flow: Ember.Object.create title: "Fake Title"

  appendBasicComponent(this, componentAttrs)
  click '.remove-column'

test 'it forwards viewCard', ->
  targetObject =
    externalAction: (card) ->
      equal card, "test"
  componentAttrs =
    viewCard: 'externalAction'
    targetObject: targetObject

  component = ETahi.FlowColumnComponent.create(componentAttrs)
  component.send 'viewCard', 'test'

test "setFlowTitle action should send saveFlow action", ->
  targetObject =
    externalAction: (flow) ->
      equal flow.get('title'), "title"
  componentAttrs =
    saveFlow: 'externalAction'
    targetObject: targetObject
    flow: Ember.Object.create title: "Fake Title"

  component = ETahi.FlowColumnComponent.create(componentAttrs)
  component.send 'setFlowTitle', { text: "title" }

test "formattedFlowTitle returns an {id: text:} object", ->
  flow = Ember.Object.create title: "Up for grabs"
  component = ETahi.FlowColumnComponent.create(flow: flow)
  keys = Ember.keys(component.get('formattedFlowTitle'))
  ok keys.contains('id')
  ok keys.contains('text')
