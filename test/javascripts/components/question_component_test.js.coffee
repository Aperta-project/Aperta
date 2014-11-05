module 'Unit: components/question'

test 'its model will come from its tasks questions by ident', ->
  q1 = Ember.Object.create(ident: "foo")
  q2 = Ember.Object.create(ident: "bar")
  task = Ember.Object.create(questions: [q1, q2])
  component = ETahi.QuestionComponent.create(task: task, ident: "bar")
  equal component.get('model'), q2, 'Finds its model by ident'

test 'it creates a new question and adds it to the task if it cant find one', ->
  q1 = Ember.Object.create(ident: "foo")
  fakeStore =
    createRecord: (type, {question, task, ident}) ->
      equal type, 'question', 'creates a new question'
      Ember.Object.create(ident: ident, task: task, question: question)
  task = Ember.Object.create(questions: [q1], store: fakeStore)

  component = ETahi.QuestionComponent.create(task: task, ident: "bar")
  model = component.get('model')
  equal model.get('ident'), 'bar', "The model has the task's ident"
  ok task.get('questions').contains(model), 'the model is added to the task'
