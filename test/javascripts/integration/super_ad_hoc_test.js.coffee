module 'Integration: Super AdHoc Card',
  setup: ->
    setupApp integration: true
    TahiTest.paperId = 4243
    TahiTest.adHocTaskId = 197

    paperResponse =
      phases: [
        id: 40
        name: "Submission Data"
        position: 1
        paper_id: TahiTest.paperId
        tasks: [
          id: TahiTest.adHocTaskId
          type: "Task"
        ]
      ]
      tasks: [
        id: TahiTest.adHocTaskId
        title: "Super Ad-Hoc"
        type: "Task"
        completed: false
        body: []
        paper_title: "Fake Paper"
        role: null
        phase_id: 40
        paper_id: TahiTest.paperId
        lite_paper_id: TahiTest.paperId
        assignee_ids: []
        assignee_id: fakeUser.id
        question_ids: [TahiTest.questionId]
      ]
      lite_papers: [
        id: TahiTest.paperId
        title: "Fake Paper"
        paper_id: TahiTest.paperId
        short_title: "Paper"
        submitted: false
      ]
      users: [fakeUser]
      affiliations: []
      figures: []
      author_groups: [
        id: 41
        name: "First Author"
        author_ids: [fakeUser.id]
        paper_id: TahiTest.paperId
      ]
      authors: [
        id: fakeUser.id
        first_name: "Fake"
        middle_initial: null
        last_name: "User"
        email: "fakeuser@example.com"
        affiliation: null
        secondary_affiliation: null
        title: null
        corresponding: false
        deceased: false
        department: null
        position: 1
        author_group_id: 41
      ]
      supporting_information_files: []
      journals: [
        id: 3
        name: "Fake Journal"
        logo_url: "/images/no-journal-image.gif"
        paper_types: ["Research"]
        task_types: []
        manuscript_css: null
      ]
      questions: []
      paper:
        id: TahiTest.paperId
        short_title: "Paper"
        title: "Fake Paper"
        body: null
        submitted: false
        paper_type: "Research"
        status: null
        phase_ids: [40]
        figure_ids: []
        author_group_ids: [41]
        supporting_information_file_ids: []
        reporting_guidelines_ids: []
        assignee_ids: [fakeUser.id]
        editor_ids: []
        reviewer_ids: []
        tasks: [
          id: TahiTest.adHocTaskId
          type: "task"
        ]
        journal_id: 3

    server.respondWith 'GET', /\/papers\/\d+\/manuscript_manager/, [
      200
      'Tahi-Authorization-Check': 'true'
      JSON.stringify {}
    ]

    server.respondWith 'GET', "/papers/#{TahiTest.paperId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]

    server.respondWith 'PUT', /\/tasks\/\d+/, [
      204, {"Content-Type": "application/json"}, JSON.stringify {}
    ]

test "Adding a text block to an AdHoc Task", ->
  visit "/papers/#{TahiTest.paperId}/manage"
  .then -> ok exists find '.card-content:contains("Super Ad-Hoc")'

  click '.card-content:contains("Super Ad-Hoc")'
  click '.adhoc-content-toolbar .glyphicon-plus'
  click '.adhoc-content-toolbar .adhoc-toolbar-item--text'
  .then ->
    ok exists find '.inline-edit-form div[contenteditable]'
    ok exists find '.button--disabled:contains("Save")'
  andThen ->
    Em.$('.inline-edit-form div[contenteditable]')
    .html("New contenteditable, yahoo!")
    .trigger('keyup')
    click '.task-body .inline-edit-form .button--green:contains("Save")'
    ok Em.$.trim(find('p.inline-edit').text()).indexOf('yahoo') isnt -1
  click '.overlay-close-button:first'
