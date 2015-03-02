`import QuestionComponent from 'tahi/pods/components/question/component'`

QuestionSelectComponent = QuestionComponent.extend
  selectedData: Em.computed 'model.answer', ->
    @get('source').findBy 'id', parseInt(@get('model.answer'))


`export default QuestionSelectComponent`
