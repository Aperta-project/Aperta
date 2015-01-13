`import Ember from 'ember'`

FlowTaskGroupComponent = Ember.Component.extend
  tagName: 'li'

  actions:
    viewCard: (task) ->
      @sendAction('viewCard', task)

`export default FlowTaskGroupComponent`
