`import Ember from 'ember'`

StyleguideRoute = Ember.Route.extend

  renderTemplate: (controller, model) ->
    @render('styleguide', {
      into: 'application',
      controller: 'styleguide'
    })

    # TODO: Render overlays manually below

    # @render('overlays/activity', {
    #   into: 'styleguide',
    #   outlet: "white-overlay",
    #   controller: 'application'
    # })

  setupController: (controller, model) ->
    journal = @store.find "journal", 1

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
      id: 1
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

    user2 = {
      id: 2
      fullName: "Ruby Twosday"
      firstName: "Ruby"
      avatarUrl: "/images/profile-no-image.png"
      username: "ruby"
      email: "ruby.jones@example.com"
      siteAdmin: false
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
      title: 'Long Paper Title of Amazingness'
      shortTitle: 'Short Paper Title',
      roles: []
    })

    role = {
      name: "Test Role"
      journal: journal
      canAdministerJournal: true
      canViewAssignedManuscriptManagers: true
      canViewAllManuscriptManagers: true
      canViewFlowManager: true
      flows: []
    }

    paper2 = @store.find("paper", 1)

    taskIncomplete2 = @store.createRecord "task",
      title: "Ethics"
      position: 1

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

    task = Ember.Object.create(
      title: "Styleguide Card"
      questions: [fakeQuestion]
    )

    phase1 = @store.createRecord 'phase',
      name: 'Submission Data'
      paper: paper
      position: 1
      tasks: [taskIncomplete2]

    phase2 = @store.createRecord 'phase',
      name: 'Phase 2'
      paper: paper

    arrayOfOptions = [
      { id: 1, text: 'Text 1'},
      { id: 2, text: 'Text 2'},
      { id: 3, text: 'Text 3'}
    ]

    questionAttachment = {
      question: fakeQuestion,
      filename: "foo.png",
      src: "foo.txt",
      status: "za",
      title: "Test Question Attachment"
    }

    cities = [
      {
        id: 1,
        text: "New York"
      },
      {
        id: 2,
        text: "Chicago"
      },
      {
        id: 3,
        text: "San Francisco"
      },
      {
        id: 4,
        text: "Dallas"
      },
      {
        id: 5,
        text: "Atlanta"
      }
    ]

    # Ember-data versions of Users
    user3 = @store.createRecord 'user', user
    user4 = @store.createRecord 'user', user2

    comment1 = @store.createRecord 'comment', {
      body: "These fine words are a test comment on Open Science",
      commenter: user3
    }

    comment2 = @store.createRecord 'comment', {
      body: "These fine words are a test comment on Open Everything",
      commenter: user4
    }

    comments = [comment1, comment2]

    inlineEditBody = {
      subject: "Greetings!", value: "Welcome to Vulcan!"
    }

    commentReply = {
      commenter: user
      replier: user2
      task: task
      body: "Here's a Test Comment Reply"
    }

    journalTaskType = @store.createRecord 'JournalTaskType',
      title: "Ad-Hoc"
      kind: "Task"
      journal: journal

    flow = @store.find 'flow', 1
    users = @store.find 'user'

    journalRoles = @store.find("role")

    autoSuggestData = [{
      fullName: 'Joe Bob', email: 'joe.bob@example.com'
    },
    { fullName: 'Bob Joe', email: 'bob.joe@example.com' }]

    controller.set('arrayOfOptions', arrayOfOptions)
    controller.set('cities', cities)
    controller.set('comment', comment1)
    controller.set('commentReply', commentReply)
    controller.set('comments', comments)
    controller.set('flash', flash)
    controller.set('flashMessage', flash.messages[1])
    controller.set('flow', flow)
    controller.set('fullAuthor', fullAuthor)
    controller.set('inlineEditBody', inlineEditBody)
    controller.set('journalRoles', journalRoles)
    controller.set('journalTaskType', journalTaskType)
    controller.set('newAuthor', newAuthor)
    controller.set('paper', paper)
    controller.set('paper2', paper2)
    controller.set('phase', phase1)
    controller.set('role', role)
    controller.set('roles', [role])
    controller.set('supportedDownloadFormats', supportedDownloadFormats)
    controller.set('task', task)
    controller.set('taskComplete', taskComplete)
    controller.set('taskIncomplete', taskIncomplete)
    controller.set('upload', upload)
    controller.set('user', user)
    controller.set('user2', user2)
    controller.set('user3', user3)
    controller.set('user4', user4)
    controller.set('users', users)
    controller.set('autoSuggestData', autoSuggestData)
    controller.set('selectBoxData', autoSuggestData)

  actions:
    selectAutoSuggestItem: ->

`export default StyleguideRoute`
