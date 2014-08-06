module 'Integration: Reporting Guidelines Card',
  setup: ->
    setupApp integration: true
    TahiTest.paperId = 4245
    TahiTest.reportingGuidelinesId = 19347
    TahiTest.questionId = 553

    questionResponse =
      question:
        id: TahiTest.questionId
        ident: "reporting_guidelines.systematic_reviews"
        question: "Systematic Reviews"
        answer: "false"
        additional_data: [{}]
        task_id: TahiTest.reportingGuidelinesId
        question_attachment_id: null
      question_attachments: []

    # we have to change the answer to true on click
    questionModifiedResponse =
      question:
        id: TahiTest.questionId
        ident: "reporting_guidelines.systematic_reviews"
        question: "Systematic Reviews"
        answer: "true"
        additional_data: [{}]
        task_id: TahiTest.reportingGuidelinesId
        question_attachment_id: null
      question_attachments: []

    paperResponse =
      phases: [
        id: 40
        name: "Submission Data"
        position: 1
        paper_id: TahiTest.paperId
        tasks: [
          id: TahiTest.reportingGuidelinesId
          type: "ReportingGuidelinesTask"
        ]
      ]
      tasks: [
        id: TahiTest.reportingGuidelinesId
        title: "Reporting Guidelines"
        type: "StandardTasks::ReportingGuidelinesTask"
        completed: false
        body: null
        paper_title: "Fake Paper"
        role: "author"
        phase_id: 40
        paper_id: TahiTest.paperId
        lite_paper_id: TahiTest.paperId
        assignee_ids: []
        assignee_id: fakeUser.user.id
        question_ids: [TahiTest.questionId]
      ]
      lite_papers: [
        id: TahiTest.paperId
        title: "Fake Paper"
        paper_id: TahiTest.paperId
        short_title: "Paper"
        submitted: false
      ]
      users: [fakeUser.user]
      affiliations: []
      figures: []
      author_groups: [
        id: 41
        name: "First Author"
        author_ids: [fakeUser.user.id]
        paper_id: TahiTest.paperId
      ]
      authors: [
        id: fakeUser.user.id
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
        task_types: ["StandardTasks::ReportingGuidelinesTask"]
        manuscript_css: null
      ]
      questions: [questionResponse.question]
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
        assignee_ids: [fakeUser.user.id]
        editor_ids: []
        reviewer_ids: []
        tasks: [
          id: TahiTest.reportingGuidelinesId
          type: "reportingGuidelinesTask"
        ]
        journal_id: 3

    reportingGuidelinesResponse =
      lite_papers: [
        id: TahiTest.paperId
        title: "Fake Paper"
        paper_id: TahiTest.paperId
        short_title: "Paper"
        submitted: false
      ]
      users: [fakeUser.user]
      affiliations: []
      task:
        id: TahiTest.reportingGuidelinesId
        title: "Reporting Guidelines"
        type: "StandardTasks::ReportingGuidelinesTask"
        completed: false
        body: null
        paper_title: "Fake Paper"
        role: "author"
        phase_id: 40
        paper_id: TahiTest.paperId
        lite_paper_id: TahiTest.paperId
        assignee_ids: []
        assignee_id: fakeUser.user.id

    server.respondWith 'GET', "/papers/#{TahiTest.paperId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]

    server.respondWith 'GET', "/tasks/#{TahiTest.reportingGuidelinesId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify reportingGuidelinesResponse
    ]

    server.respondWith 'PUT', /\/tasks\/\d+/, [
      204, {"Content-Type": "application/json"}, JSON.stringify {}
    ]

    server.respondWith 'PUT', /\/questions\/\d+/, [
      200, {"Content-Type": "application/json"}, JSON.stringify questionModifiedResponse
    ]

test 'Supporting Guideline is a meta data card, contains the right questions and sub-questions', ->
  findQuestionLi = (questionText) ->
    find('.question .item').filter (i, el) -> Em.$(el).find('label').text().trim() is questionText

  visit "/papers/#{TahiTest.paperId}/edit"
  .then -> ok exists find '.card-content:contains("Reporting Guidelines")'

  click '.card-content:contains("Reporting Guidelines")'
  .then ->
    equal find('.question .item').length, 6
    equal find('h1').text(), 'Reporting Guidelines'
    questionLi = findQuestionLi 'Systematic Reviews'
    ok exists questionLi.find('.additional-data.hidden')

  click 'input[name="reporting_guidelines.systematic_reviews"]'
  .then ->
    questionLi = findQuestionLi 'Systematic Reviews'
    ok !(exists questionLi.find('.additional-data.hidden'))
    ok exists questionLi.find('.additional-data')
    additionalDataText = questionLi.find('.additional-data').first().text().trim()
    ok additionalDataText.indexOf('Select & upload') > -1
    ok additionalDataText.indexOf('Provide a completed PRISMA checklist as supporting information.') > -1

test 'clinical trial question is auto-checked based on answer from ethics question', ->
  ok true
