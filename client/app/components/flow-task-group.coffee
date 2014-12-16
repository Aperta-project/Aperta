`import Ember from 'ember'`

FlowTaskGroupComponent = Ember.Component.extend
  tagName: 'li'
  tasks: ( ->
    @get('flow.tasks').filterBy('litePaper', @get('litePaper'))
  ).property('flow.tasks.@each.litePaper', 'litePaper')

  actions:
    viewCard: (task) ->
      @sendAction('viewCard', task)

`export default FlowTaskGroupComponent`
