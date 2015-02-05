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

    taskIncomplete = {
      title: "Add Author"
    }

    taskComplete = {
      title: "Add Author"
      completed: true
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

    phases = [
      {
        name: 'Submission Data'
        tasks: [
          {
            title: "Cool"
          },
          @taskIncomplete,
          @taskComplete
        ]
      },
      {
        name: 'Phase 2'
        tasks: [
          {
            title: "Cool"
          },
          @taskIncomplete,
          @taskComplete
        ]
      }
    ]

    paper = {
      title: 'Long Paper Amazingness'
      shortTitle: 'Short Paper Title, Guh.'
      phases: phases
    }

    supportedDownloadFormats = [
      {
        format: "docx",
        url: "https://tahi.example.com/export/docx",
        description: "This converts from docx to HTML"
      }
    ]

    controller.set('upload', upload)
    controller.set('flash', flash)
    controller.set('model', user)
    controller.set('newAuthor', newAuthor)
    controller.set('fullAuthor', fullAuthor)
    controller.set('taskIncomplete', taskIncomplete)
    controller.set('taskComplete', taskComplete)
    controller.set('phases', phases)
    controller.set('paper', paper)
    controller.set('supportedDownloadFormats', supportedDownloadFormats)

`export default StyleguideRoute`
