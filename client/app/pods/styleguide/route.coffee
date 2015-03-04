`import Ember from 'ember'`

StyleguideRoute = Ember.Route.extend

  setupController: (controller, model) ->
    upload = {
      id: 1
      file: {
        name: "Manuscript.docx"
        # preview:
      }
      error: "Errrrs"
      dataLoaded: 5000
      dataTotal: 10000
    }

    uploads = {
      id: 1
      title: 'Learn Ember.js'
      isCompleted: true
    }

    user = {
      id: 2
      fullName: "Charlotte Jones"
      firstName: "Charlotte"
      avatarUrl: "/images/profile-no-image.png"
      username: "charlotte"
      email: "charlotte.jones@example.com"
      siteAdmin: true
      affiliationIds: [
        2
      ]
    }

    newAuthor = {
      firstName: "Albert"
      middleInitial: "E"
      lastName: "Einstein"
      email: "al@lvh.me"
      title: 'Patent Clerk'
      department: "Somewhere"
      deceased: true
      errors: {
        'uno': 'oops'
      }
    }

    fullAuthor = {
      model: {
        firstName: "Albert"
        middleInitial: "E"
        lastName: "Einstein"
        fullName: "Albert Einstein"
        email: "al@lvh.me"
        title: 'Patent Clerk'
        department: "Somewhere"
        deceased: true
        errors: {
          'uno': 'oops'
        }
      }
    }

    flash = {
      messages: [
        {
          text: 'Just Lettin Ya Know'
        },
        {
          text: 'Whoa Nelly'
          type: 'error'
        },
        {
          text: 'Awww Ya'
          type: 'success'
        },
        {
          text: 'Be Aware'
          type: 'alert'
        }
      ]
    }

    paper = @store.createRecord("paper", {
      title: 'Long Paper Amazingness'
      shortTitle: 'Short Paper Title, Guh.'
    })

    taskIncomplete2 = @store.createRecord "task",
      title: "Ethics"

    phase1 = @store.createRecord 'phase',
      name: 'Submission Data'
      paper: paper

    phase2 = @store.createRecord 'phase',
      name: 'Phase 2'
      paper: paper

    taskIncomplete =
      title: "Ethics"

    taskComplete =
      title: "Add Author"
      completed: true

    supportedDownloadFormats = [
      {
        format: "docx",
        url: "https://tahi.example.com/export/docx",
        description: "This converts from docx to HTML"
      }
    ]

    fakeQuestion = Ember.Object.create
      ident: "foo"
      save: -> null
      additionalData: [{}]
      question: "Test Question"
      answer: true
    task = Ember.Object.create(questions: [fakeQuestion])

    arrayOfOptions = [
      { id: 1, text: 'Text 1'},
      { id: 2, text: 'Text 2'},
      { id: 3, text: 'Text 3'}
    ]

    controller.set('user', user)
    controller.set('upload', upload)
    controller.set('flash', flash)
    controller.set('newAuthor', newAuthor)
    controller.set('fullAuthor', fullAuthor)
    controller.set('phases', [phase1, phase2])
    controller.set('paper', paper)
    controller.set('taskIncomplete', taskIncomplete)
    controller.set('taskComplete', taskComplete)
    controller.set('supportedDownloadFormats', supportedDownloadFormats)
    controller.set('arrayOfOptions', arrayOfOptions)
    controller.set('task', task)

`export default StyleguideRoute`
