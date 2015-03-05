`import QuestionComponent from 'tahi/pods/components/question/component'`

QuestionMultiRadioComponent = QuestionComponent.extend
  actions:
    select: (arg) ->
      this.set 'model.answer', arg

`export default QuestionMultiRadioComponent`
