# this test is mosty here to take care of the 6 nested components it uses
# in one shot rather than splitting them up, and to make sure that changes
# in the nested components properly propogate back up to the task.
moduleForComponent 'question-check', 'Component: question-check',
  needs: [
    'template:components/question/check_component'
    'component:check-box'
    'template:components/additional-datasets'
    'component:datum-definition'
    'template:components/dataset-contact'
    'template:components/dataset-description'
    'template:components/dataset-doi'
    'template:components/dataset-reasons'
    'template:components/dataset-title'
    'template:components/dataset-url'
  ]

test 'it renders its question', ->
  fakeQuestion = Ember.Object.create
    ident: "foo"
    save: -> null
    additionalData: [{}]
    question: "Test Question"
    answer: true
  task = Ember.Object.create(questions: [fakeQuestion])
  component = @subject
    ident: "foo"
    task: task

  $component = @append()
  ok $component.find("label:contains('Test Question')").length

test 'with additional-datasets it renders them and a buton to add more', ->
  fakeQuestion = Ember.Object.create
    ident: "foo"
    save: -> null
    additionalData: [{}, {}]
    question: "Test Question"
    answer: true
  task = Ember.Object.create(questions: [fakeQuestion])
  template = "{{#additional-datasets}}{{/additional-datasets}}"
  component = @subject
    ident: "foo"
    task: task
    template: Ember.Handlebars.compile(template)

  $component = @append()
  equal $component.find(".question-dataset").length, 2, "Renders a dataset for each one in the model"
  ok $component.find("button:contains('Add Dataset')").length, "Renders an Add Dataset button"

test 'it uses dataset-* components to render attributes on additonalData', ->
  additionalDataItem =
    contact: "test contact"
    description: "test description"
    accession: "test doi"
    reasons: "test reasons"
    title: "test title"
    url: "test url"
  fakeQuestion = Ember.Object.create
    ident: "foo"
    save: -> null
    additionalData: [additionalDataItem]
    question: "Test Question"
    answer: true
  task = Ember.Object.create(questions: [fakeQuestion])
  template = "{{#additional-datasets}}
                {{dataset-contact}}
                {{dataset-description}}
                {{dataset-doi}}
                {{dataset-reasons}}
                {{dataset-title}}
                {{dataset-url}}
              {{/additional-datasets}}"
  component = @subject
    ident: "foo"
    task: task
    template: Ember.Handlebars.compile(template)

  $component = @append()
  assertValue = (component, selector, value, message) ->
    equal(component.find(selector).val(), value, message)

  assertValue $component, "textarea[name='contact']" , 'test contact', 'contact is a textarea'
  assertValue $component, "input[name='description']" , 'test description', 'description is an input'
  assertValue $component, "input[name='accession']" , 'test doi', 'doi is an input'
  equal $component.find("textarea[name='reasons']").val(), 'test reasons', 'reasons is a textarea'
  assertValue $component, "input[name='title']" , 'test title', 'title is an input'
  assertValue $component, "input[name='url']" , 'test url', 'url is an input'
  fillIn("input[name='description']", "New description")
  fillIn("textarea[name='contact']", "New contact")
  andThen ->
    equal additionalDataItem.description, 'New description', 'additionalData syncs inputs to the value of the fields'
    equal additionalDataItem.contact, 'New contact', 'additionalData syncs to the textareas to the value of the fields'
