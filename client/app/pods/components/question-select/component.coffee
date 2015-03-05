`import QuestionComponent from 'tahi/pods/components/question/component'`

QuestionSelectComponent = QuestionComponent.extend
  selectedData: Em.computed 'model.answer', ->
    id = parseInt(@get('model.answer')) or @get('model.answer')
    @get('source').findBy 'id', id
  actions:
    selectionSelected: (selection) ->
      @sendAction 'selectionSelected', selection

`export default QuestionSelectComponent`
