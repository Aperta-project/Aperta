TahiTest = {}
module 'Integration: Admin Journal User Roles, /admin/journals/:id',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp()
    TahiTest.journalId = 209
    TahiTest.editorRoleId = 8
    adminJournals =
      roles: [
        id: 7
        kind: "admin"
        name: "Admin"
        required: true
        can_administer_journal: true
        can_view_assigned_manuscript_managers: false
        can_view_all_manuscript_managers: true
        journal_id: TahiTest.journalId
      ,
        id: TahiTest.editorRoleId
        kind: "editor"
        name: "Editor"
        required: true
        can_administer_journal: false
        can_view_assigned_manuscript_managers: false
        can_view_all_manuscript_managers: false
        journal_id: TahiTest.journalId
      ,
        id: 9
        kind: "reviewer"
        name: "Reviewer"
        required: true
        can_administer_journal: false
        can_view_assigned_manuscript_managers: false
        can_view_all_manuscript_managers: false
        journal_id: TahiTest.journalId
      ]
      admin_journals: [
        id: TahiTest.journalId
        name: "Test Journal of America"
        logo_url: "https://tahi-development.s3-us-west-1.amazonaws.com/uploads/journal/logo/3/Screen%2BShot%2B2014-06-10%2Bat%2B2.59.37%2BPM.png?AWSAccessKeyId=AKIAJHFQZ6WND52M2VDQ&Signature=l34/IdieeCkMGABO7KcBNK1n8Q4%3D&Expires=1405467848"
        paper_types: ["Research"]
        task_types: [
          "ReviewerReportTask"
          "PaperAdminTask"
          "UploadManuscript::Task"
          "PaperEditorTask"
          "Declaration::Task"
          "PaperReviewerTask"
          "RegisterDecisionTask"
          "StandardTasks::TechCheckTask"
          "StandardTasks::FigureTask"
          "StandardTasks::AuthorsTask"
          "SupportingInformation::Task"
          "DataAvailability::Task"
          "FinancialDisclosure::Task"
          "CompetingInterests::Task"
        ]
        epub_cover_url: null
        epub_cover_file_name: null
        epub_css: null
        pdf_css: null
        manuscript_css: null
        description: "This is a test journal"
        paper_count: 3
        created_at: "2014-06-16T22:23:16.320Z"
        manuscript_manager_templates: [
          id: 5
          paper_type: "Research"
          template:
            phases: [
              name: "Submission Data"
              task_types: [
                "Declaration::Task"
                "StandardTasks::FigureTask"
                "SupportingInformation::Task"
                "StandardTasks::AuthorsTask"
                "UploadManuscript::Task"
              ]
              ,
              name: "Assign Editor"
              task_types: [
                "PaperEditorTask"
                "StandardTasks::TechCheckTask"
                "PaperAdminTask"
              ]
              ,
              name: "Assign Reviewers"
              task_types: ["PaperReviewerTask"]
              ,
              name: "Get Reviews"
              task_types: []
              ,
              name: "Make Decision"
              task_types: ["RegisterDecisionTask"]
            ]
          journal_id: TahiTest.journalId
        ]
        role_ids: [7, 8, 9]
      ]

    adminJournalUserResponse =
      admin_journal_user:
        id: 923
        username: "fakeuser"
        first_name: "Fake"
        last_name: "User"

    TahiTest.query = 'User'
    adminJournalUsersResults = admin_journal_users: [adminJournalUserResponse.admin_journal_user]

    TahiTest.userRoleId = 99
    userRoleResponse =
      user_role:
        id: TahiTest.userRoleId
        user_id: adminJournalUserResponse.admin_journal_user.id
        role_id: TahiTest.editorRoleId

    server.respondWith 'GET', "/admin/journals", [
      200, "Content-Type": "application/json", JSON.stringify adminJournals
    ]

    server.respondWith 'GET', "/admin/journal_users?journal_id=#{TahiTest.journalId}", [
      200, "Content-Type": "application/json", JSON.stringify adminJournalUsersResults
    ]

    server.respondWith 'GET', "/admin/journal_users?query=#{TahiTest.query}", [
      200, "Content-Type": "application/json", JSON.stringify adminJournalUsersResults
    ]

    server.respondWith 'POST', "/user_roles", [
      201, "Content-Type": "application/json", JSON.stringify userRoleResponse
    ]

    server.respondWith 'DELETE', "/user_roles/#{TahiTest.userRoleId}", [
      204, "Content-Type": "application/json", JSON.stringify {}
    ]

  teardown: -> $('.add-role-input').typeahead 'val', null

test 'admin adds a role for user', ->
  visit "/admin/journals/#{TahiTest.journalId}"
  .then -> ok exists 'tr.user-row'
  fillIn '.admin-search-input', TahiTest.query
  click '.admin-search-button'
  click '.assign-role-button'
  .then -> $('.add-role-input').typeahead 'val', 'Edit'
  .then -> click '.tt-suggestion'
  andThen -> equal $.trim(find('.assigned-role').text()), "Editor"

test 'admin removes a role for user', ->
  visit "/admin/journals/#{TahiTest.journalId}"
  fillIn '.admin-search-input', TahiTest.query
  click '.admin-search-button'
  click '.assign-role-button'
  .then -> $('.add-role-input').typeahead 'val', 'Edit'
  .then -> click '.tt-suggestion'
  click '.remove-button'
  andThen -> ok !exists '.assigned-role.token'

test 'autocomplete does not give roles the user is already assigned to', ->
  visit "/admin/journals/#{TahiTest.journalId}"
  fillIn '.admin-search-input', TahiTest.query
  click '.admin-search-button'
  click '.assign-role-button'
  .then -> $('.add-role-input').typeahead 'val', 'Edit'
  .then -> click '.tt-suggestion'
  click '.assign-role-button'
  .then -> $('.add-role-input').typeahead 'val', 'Edit'
  andThen -> ok !exists '.tt-suggestion'
