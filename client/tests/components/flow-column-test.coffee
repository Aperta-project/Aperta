`import Ember from 'ember'`
`import { test, moduleForComponent } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`

moduleForComponent 'flow-column', 'Unit: components/flow-column',
  needs: [
    'helper:display-value'
    'component:segmented-button'
    'component:progress-spinner'
    'component:flow-task-group'
    'component:select-2-single'
  ]
  setup: -> startApp()


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

  component = @subject(componentAttrs)
  component.send 'viewCard', 'test'
