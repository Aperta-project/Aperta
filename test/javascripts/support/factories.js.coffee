ETahi.Factory =

  create: (type, attrs) ->
    Ember.merge(ETahi.FactoryAttributes[type], attrs)

  createLitePaper: (paper, attrs) ->
    {short_title, title, id, submitted} = paper
    paper_id = id
    litePaperAttrs = {short_title, title, id, submitted, paper_id}
    Ember.merge(litePaperAttrs, attrs)

  addRecordToManifest: (manifest, typeName, obj, isPrimary) ->
    # the allRecords array allows easy modification of a given
    # record later
    manifest.allRecords ||= []
    manifest.allRecords.addObject(obj)

    manifest.types ||= {}
    types = manifest.types
    typeArray = types[typeName]
    if !typeArray
      types[typeName] = []
      typeArray = types[typeName]
    typeArray.addObject(obj)

    if isPrimary
      manifest.primaryRecord = obj
      manifest.primaryType = typeName
    manifest

  manifestToPayload: (manifest) ->
    {primaryRecord, primaryType} = manifest
    payload= {}
    payload[primaryType] = primaryRecord
    _.forEach manifest.types, (typeArray, typeName) ->
      records = _.map(typeArray, (d) -> d)
      if typeName == primaryType
        records = _.reject(records, (r) -> r == primaryRecord)
      if records.length > 0
        payload[(typeName + "s")] = records
    payload

   createPayload: (primaryTypeName) ->
     _addRecordToManifest = @addRecordToManifest
     _manifestToPayload = @manifestToPayload
     manifest: {types: {}}
     addRecord: (rootKey, attrs) ->
       isPrimary = (rootKey == primaryTypeName)
       @manifest = _addRecordToManifest(@manifest, rootKey, attrs, isPrimary)
       @
     toJSON: ->
       _manifestToPayload(@manifest)


ETahi.FactoryAttributes = {}
ETahi.FactoryAttributes.user =
  _rootKey: 'user'
  id: 1
  full_name: "Fake User"
  avatar_url: "/images/profile-no-image.png"
  username: "fakeuser"
  email: "fakeuser@example.com"
  admin: false
  affiliation_ids: []
ETahi.FactoryAttributes.journal =
  _rootKey: 'journal'
  id: 1
  name: "Fake Journal"
  logo_url: "/images/no-journal-image.gif"
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
  manuscript_css: null

ETahi.FactoryAttributes.paper =
  _rootKey: 'paper'
  id: 1
  short_title: "Paper"
  title: "Foo"
  body: null
  submitted: false
  paper_type: "Research"
  status: null
  phase_ids: []
  figure_ids: []
  author_group_ids: []
  supporting_information_file_ids: []
  assignee_ids: []
  editor_ids: []
  reviewer_ids: []
  tasks: []
  journal_id: 1

ETahi.FactoryAttributes.litePaper =
  _rootKey: 'lite_paper'
  id: 1
  title: "Foo"
  paper_id: 1
  short_title: "Paper"
  submitted: false

ETahi.FactoryAttributes.messageTask =
  _rootKey: 'task'
  id: 1
  title: "Message Time"
  type: "MessageTask"
  completed: false
  body: null
  paper_title: "Foo"
  role: "author"
  phase_id: null
  paper_id: null
  lite_paper_id: null
  assignee_ids: []
  assignee_id: null
  participant_ids: []
  comment_ids: []

ETahi.FactoryAttributes.comment =
  _rootKey: 'comment'
  id: 1
  commenter_id: 1
  message_task_id: 1
  body: "A sample comment"
  created_at: null
  comment_look_id: null

ETahi.FactoryAttributes.phase =
  _rootKey: 'phase'
  id: 1
  name: "Submission Data"
  position: 1
  paper_id: 1
  tasks: []
