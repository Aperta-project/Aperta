ETahi.QuestionCheckComponent = Ember.Component.extend
  tagName: 'div'
  classNames: ['question']
  layoutName: 'components/question/check_component'
  helpText: null

  model: (->
    ident = @get('ident')
    throw "you must specify an ident" unless ident

    question = @get('task.questions').findProperty('ident', ident)

    unless question
      question = @get('task.questions').createRecord
        question: @get('question')
        ident: ident

    question

  ).property('task', 'ident')

