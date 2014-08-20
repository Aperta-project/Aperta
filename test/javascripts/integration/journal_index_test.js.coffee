moduleFor 'view:journal.index', 'Unit: admin/controller:journal',

  teardown: ->
    ETahi.reset()

  setup: ->
    journal = Ember.Object.create
      title: 'test journal'

    paper = Ember.Object.create
      title: ''
      shortTitle: 'Does not matter'
      body: 'hello'

    Ember.run =>
      setupApp()

      @user =
        affiliations: [
          id: 1
          name: "skyline"
          start_date: null
          end_date: null
          email: null
          user_id: 1
        ]
        user:
          id: 1
          full_name: "Mike D"
          first_name: "Mike"
          avatar_url: "/images/profile-no-image.png"
          username: "miked"
          email: "miked@example.com"
          admin: true
          affiliation_ids: [1]

      @journals =
        roles: [
          {
            id: 1
            kind: "admin"
            name: "Admin"
            required: true
            can_administer_journal: true
            can_view_assigned_manuscript_managers: false
            can_view_all_manuscript_managers: true
            journal_id: 1
          }
          {
            id: 2
            kind: "editor"
            name: "Editor"
            required: true
            can_administer_journal: false
            can_view_assigned_manuscript_managers: false
            can_view_all_manuscript_managers: false
            journal_id: 1
          }
          {
            id: 3
            kind: "reviewer"
            name: "Reviewer"
            required: true
            can_administer_journal: false
            can_view_assigned_manuscript_managers: false
            can_view_all_manuscript_managers: false
            journal_id: 1
          }
        ]
        admin_journals: [
          id: 1
          name: "PLOS Yeti"
          logo_url: null,
          paper_types: ["Research"]
          task_types: [
          ]
          epub_cover_url: "https://tahi-development.s3-us-west-1.amazonaws.com/uploads/journal/epub_cover/1/pie.jpg?AWSAccessKeyId=AKIAJHFQZ6WND52M2VDQ&Signature=7/ZBY8X2ETH6DOEnH9TfaiW1EZw%3D&Expires=1408407463"
          epub_cover_file_name: "pie.jpg"
          epub_css: null
          pdf_css: null
          manuscript_css: null
          description: "Yeti description"
          paper_count: 6
          created_at: "2014-08-04T17:54:48.055Z"
          manuscript_manager_templates: [
            id: 1
            paper_type: "Research"
            template:
              phases: [
                {
                  name: "Submission Data"
                  task_types: [
                  ]
                }
                {
                  name: "Assign Editor"
                  task_types: [
                  ]
                }
                {
                  name: "Assign Reviewers"
                  task_types: ["StandardTasks::PaperReviewerTask"]
                }
                {
                  name: "Get Reviews"
                  task_types: []
                }
                {
                  name: "Make Decision"
                  task_types: ["StandardTasks::RegisterDecisionTask"]
                }
              ]

            journal_id: 1
          ]
          role_ids: [
            1
            2
            3
          ]
        ]

      @journals2 =
        roles: [
          {
            id: 1
            kind: "admin"
            name: "Admin"
            required: true
            can_administer_journal: true
            can_view_assigned_manuscript_managers: false
            can_view_all_manuscript_managers: true
            journal_id: 2
          }
          {
            id: 2
            kind: "editor"
            name: "Editor"
            required: true
            can_administer_journal: false
            can_view_assigned_manuscript_managers: false
            can_view_all_manuscript_managers: false
            journal_id: 2
          }
          {
            id: 3
            kind: "reviewer"
            name: "Reviewer"
            required: true
            can_administer_journal: false
            can_view_assigned_manuscript_managers: false
            can_view_all_manuscript_managers: false
            journal_id: 2
          }
        ]
        admin_journals: [
          id: 2
          name: "PLOS Bigfoot"
          logo_url: '/images/profile-no-image.png',
          paper_types: ["Research"]
          task_types: [
          ]
          epub_cover_url: "https://tahi-development.s3-us-west-1.amazonaws.com/uploads/journal/epub_cover/1/pie.jpg?AWSAccessKeyId=AKIAJHFQZ6WND52M2VDQ&Signature=7/ZBY8X2ETH6DOEnH9TfaiW1EZw%3D&Expires=1408407463"
          epub_cover_file_name: "pie.jpg"
          epub_css: null
          pdf_css: null
          manuscript_css: null
          description: "Yeti description"
          paper_count: 6
          created_at: "2014-08-04T17:54:48.055Z"
          manuscript_manager_templates: [
            id: 1
            paper_type: "Research"
            template:
              phases: [
                {
                  name: "Submission Data"
                  task_types: [
                  ]
                }
                {
                  name: "Assign Editor"
                  task_types: [
                  ]
                }
                {
                  name: "Assign Reviewers"
                  task_types: ["StandardTasks::PaperReviewerTask"]
                }
                {
                  name: "Get Reviews"
                  task_types: []
                }
                {
                  name: "Make Decision"
                  task_types: ["StandardTasks::RegisterDecisionTask"]
                }
              ]

            journal_id: 2
          ]
          role_ids: [
            1
            2
            3
          ]
        ]

      @journal_ids = admin_journal_users: []

      @eventStream = {"enabled":null,"url":"http://localhost:8080/stream?token=token123","eventNames":["98764"]}

      controller = ETahi.__container__.lookup 'controller:journalIndex'
      @subject().set 'controller', controller
      controller.set 'content', paper

      server.respondWith 'GET', "/users/1", [
        200, {"Content-Type": "application/json"}, JSON.stringify @user
      ]

      server.respondWith 'GET', "/admin/journal_users?journal_id=1", [
        200, {"Content-Type": "application/json"}, JSON.stringify @journal_ids
      ]

      server.respondWith 'GET', "/admin/journal_users?journal_id=2", [
        200, {"Content-Type": "application/json"}, JSON.stringify @journal_ids
      ]

      server.respondWith 'GET', "/event_stream", [
        200, {"Content-Type": "application/json"}, JSON.stringify @eventStream
      ]

test 'conditional show of Journal name', ->
  server.respondWith 'GET', "/admin/journals", [
    200, {"Content-Type": "application/json"}, JSON.stringify @journals
  ]

  visit '/admin/journals/1'
    .then =>
      ok find('h1').text().indexOf(@subject().controller.get("name")) isnt -1
      ok find('h1').text().indexOf(@subject().controller.get("logoUrl")) is -1

test 'conditional show of Journal logo', ->
  server.respondWith 'GET', "/admin/journals", [
    200, {"Content-Type": "application/json"}, JSON.stringify @journals2
  ]

  visit '/admin/journals/2'
    .then =>
      ok find('h1').text().indexOf(@subject().controller.get("name")) is -1
      ok find('h1 img').attr("src").indexOf(@subject().controller.get("logoUrl")) isnt -1
