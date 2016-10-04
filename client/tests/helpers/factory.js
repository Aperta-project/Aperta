// Generated by CoffeeScript 1.10.0
import deNamespaceTaskType from 'tahi/lib/de-namespace-task-type';
import FactoryGuy from 'ember-data-factory-guy';
var Factory, FactoryAttributes;

Factory = {
  typeIds: {},
  resetFactoryIds: function() {
    return this.typeIds = {};
  },
  getNewId: function(type) {
    var typeIds;
    typeIds = this.typeIds;
    if (!typeIds[type]) {
      typeIds[type] = 0;
    }
    typeIds[type] += 1;
    return typeIds[type];
  },
  createRecord: function(type, attrs) {
    var baseAttrs, newId, recordAttrs;
    if (attrs == null) {
      attrs = {};
    }
    if (!attrs.id) {
      newId = this.getNewId(type);
      recordAttrs = _.extend(attrs, {
        id: newId
      });
    } else {
      recordAttrs = attrs;
    }
    baseAttrs = FactoryAttributes[type];
    if (!baseAttrs) {
      throw 'No factory exists in FactoryAttributes for type: ' + type + '. You may need to define this.';
    }
    return _.defaults(recordAttrs, baseAttrs);
  },

  createPermission: function(klass, id, permissions) {
    Ember.run(() => {
      let permissions_hash = {};
      _.each(permissions, p => permissions_hash[p] = {states: ['*']});

      return FactoryGuy.make('permission', {
        id: `${klass.camelize()}+${id}`,
        object: {id, type: klass},
        permissions: permissions_hash
      });
    });
  },

  createList: function(numberOfRecords, type) {
    return _(numberOfRecords).times(function() {
      return this.createRecord(type);
    });
  },
  setForeignKey: function(model, sourceModel, options) {
    var inverseKeyName, keyName;
    if (options == null) {
      options = {};
    }
    keyName = options.keyName || sourceModel._rootKey;
    model[keyName + '_id'] = sourceModel.id;
    if (inverseKeyName = options.inverse) {
      this.setForeignKey(sourceModel, model, {
        keyName: inverseKeyName
      });
    }
    return [model, sourceModel];
  },
  addHasMany: function(model, models, options) {
    return this.setHasMany(model, models, _.extend(options, {
      merge: true
    }));
  },
  mergeArrays: function(model, key, values) {
    var currentValues;
    model[key] || (model[key] = []);
    currentValues = model[key];
    return model[key] = _.union(currentValues, values);
  },
  setHasMany: function(model, models, options) {
    var deNamespace, inverseKeyName, key, keyName, modelIds;
    if (options == null) {
      options = {};
    }
    keyName = options.keyName || _.first(models)._rootKey;
    deNamespace = deNamespaceTaskType;
    if (options.embed) {
      key = keyName + 's';
      modelIds = _.map(models, function(t) {
        return {
          id: t.id,
          type: deNamespace(t.type)
        };
      });
    } else {
      key = keyName + '_ids';
      modelIds = _.pluck(models, 'id');
    }
    if (options.merge) {
      this.mergeArrays(model, key, modelIds);
    } else {
      model[key] = modelIds;
    }
    if (inverseKeyName = options.inverse) {
      _.forEach(models, (function(_this) {
        return function(m) {
          return _this.setForeignKey(m, model, {
            keyName: inverseKeyName
          });
        };
      })(this));
    }
    return [model, models];
  },
  addEmbeddedHasMany: function(model, models, options) {
    return this.setEmbeddedHasMany(model, models, _.extend(options, {
      merge: true
    }));
  },
  setEmbeddedHasMany: function(model, models, options) {
    if (options == null) {
      options = {};
    }
    return this.setHasMany(model, models, _.extend(options, {
      embed: true
    }));
  },
  addRecordToManifest: function(manifest, typeName, obj, isPrimary) {
    var typeArray, types;
    manifest.allRecords || (manifest.allRecords = []);
    manifest.allRecords.addObject(obj);
    manifest.types || (manifest.types = {});
    types = manifest.types;
    typeArray = types[typeName];
    if (!typeArray) {
      types[typeName] = [];
      typeArray = types[typeName];
    }
    typeArray.addObject(obj);
    if (isPrimary) {
      manifest.primaryRecord = obj;
      manifest.primaryType = typeName;
    }
    return manifest;
  },
  manifestToPayload: function(manifest) {
    var payload, primaryRecord, primaryType;
    primaryRecord = manifest.primaryRecord, primaryType = manifest.primaryType;
    payload = {};
    if (primaryType && primaryRecord) {
      payload[primaryType] = primaryRecord;
    }
    _.forEach(manifest.types, function(typeArray, typeName) {
      var records;
      records = _.map(typeArray, function(d) {
        return d;
      });
      if (typeName === primaryType) {
        records = _.reject(records, function(r) {
          return r === primaryRecord;
        });
      }
      if (records.length > 0) {
        var singularRecord = payload[typeName];
        delete payload[typeName];
        return payload[typeName + 's'] = records.concat(Ember.makeArray(singularRecord));
      }
    });
    return payload;
  },
  createPayload: function(primaryTypeName) {
    var _addRecordToManifest, _manifestToPayload;
    _addRecordToManifest = this.addRecordToManifest;
    _manifestToPayload = this.manifestToPayload;
    return {
      manifest: {
        types: {}
      },
      createRecord: function(type, attrs) {
        var newRecord;
        newRecord = Factory.createRecord(type, attrs);
        this.addRecord(newRecord);
        return newRecord;
      },
      addRecords: function(records, options) {
        if (options == null) {
          options = {};
        }
        _.forEach(records, (function(_this) {
          return function(r) {
            return _this.addRecord(r, options);
          };
        })(this));
        return this;
      },
      addRecord: function(record, options) {
        var isPrimary, rootKey;
        if (options == null) {
          options = {};
        }
        rootKey = options.rootKey || record._rootKey;
        isPrimary = rootKey === primaryTypeName;
        this.manifest = _addRecordToManifest(this.manifest, rootKey, record, isPrimary);
        return this;
      },
      toJSON: function() {
        return _manifestToPayload(this.manifest);
      }
    };
  },
  createBasicPaper: function(defs) {
    var allTasks, ef, journal, litePaper, paper, phases, phasesAndTasks;
    ef = Factory;
    journal = ef.createRecord('Journal', defs.journal || {});
    paper = ef.createRecord('Paper', _.omit(defs.paper, 'phases') || {});
    litePaper = Factory.createLitePaper(paper);
    ef.setForeignKey(paper, journal);
    phasesAndTasks = _.map(defs.paper.phases, function(phase) {
      var phaseRecord, taskRecords;
      phaseRecord = ef.createRecord('Phase', _.omit(phase, 'tasks'));
      taskRecords = _.map(phase.tasks, function(task) {
        var taskAttrs, taskType;
        taskType = _.keys(task)[0];
        taskAttrs = task[taskType];
        return ef.createRecord(taskType, taskAttrs);
      });
      ef.setEmbeddedHasMany(phaseRecord, taskRecords, {
        inverse: 'phase'
      });
      return [phaseRecord, taskRecords];
    });
    allTasks = _.reduce(phasesAndTasks, (function(memo, arg) {
      var phase, tasks;
      phase = arg[0], tasks = arg[1];
      return memo.concat(tasks);
    }), []);
    phases = _.map(phasesAndTasks, _.first);
    ef.setHasMany(paper, phases, {
      inverse: 'paper'
    });
    ef.setEmbeddedHasMany(paper, allTasks, {
      inverse: 'paper'
    });
    _.forEach(allTasks, function(task) {
      return task.lite_paper_id = paper.id;
    });
    return [].concat(paper, litePaper, journal, phases, allTasks);
  },
  createLitePaper: function(paper) {
    var id, paperAttrs, paper_id, publishingState, short_title, title;
    short_title = paper.short_title, title = paper.title, id = paper.id, publishingState = paper.publishingState;
    paper_id = id;
    paperAttrs = {
      short_title: short_title,
      title: title,
      id: id,
      publishingState: publishingState,
      paper_id: paper_id
    };
    return Factory.createRecord('LitePaper', paperAttrs);
  },
  createLitePaperWithRoles: function(paper, oldRoles) {
    var id, lp, paperAttrs, paper_id, publishingState, short_title, title;
    short_title = paper.short_title, title = paper.title, id = paper.id, publishingState = paper.publishingState;
    paper_id = id;
    paperAttrs = {
      short_title: short_title,
      title: title,
      id: id,
      publishingState: publishingState,
      paper_id: paper_id
    };
    lp = Factory.createRecord('LitePaper', paperAttrs);
    lp.oldRoles = oldRoles;
    return lp;
  },
  createPhase: function(paper, attrs) {
    var newPhase;
    if (attrs == null) {
      attrs = {};
    }
    newPhase = this.createRecord('Phase', attrs);
    this.addHasMany(paper, [newPhase], {
      inverse: 'paper'
    });
    return newPhase;
  },
  createAuthor: function(paper, attrs) {
    var newAuthor;
    if (attrs == null) {
      attrs = {};
    }
    newAuthor = this.createRecord('Author', attrs);
    this.addHasMany(paper, [newAuthor], {
      inverse: 'paper'
    });
    return newAuthor;
  },
  createTask: function(type, paper, phase, attrs) {
    var newTask;
    if (attrs == null) {
      attrs = {};
    }
    newTask = this.createRecord(type, _.extend(attrs, {
      lite_paper_id: paper.id
    }));
    newTask.links = {
      nested_questions: '/api/tasks/' + newTask.id + '/nested_questions',
      nested_question_answers: '/api/tasks/' + newTask.id + '/nested_question_answers'
    };
    this.addHasMany(paper, [newTask], {
      inverse: 'paper',
      embed: true
    });
    this.addHasMany(phase, [newTask], {
      inverse: 'phase',
      embed: true
    });
    return newTask;
  },
  createMMT: function(journal, attrs) {
    var newMMT;
    if (attrs == null) {
      attrs = {};
    }
    newMMT = this.createRecord('ManuscriptManagerTemplate', attrs);
    this.addHasMany(journal, [newMMT], {
      inverse: 'journal'
    });
    return newMMT;
  },
  createPhaseTemplate: function(mmt, attrs) {
    var newPhaseTemplate;
    if (attrs == null) {
      attrs = {};
    }
    newPhaseTemplate = this.createRecord('PhaseTemplate', attrs);
    this.addHasMany(mmt, [newPhaseTemplate], {
      inverse: 'manuscript_manager_template'
    });
    return newPhaseTemplate;
  },
  createJournalTaskType: function(journal, taskType) {
    var jtt;
    jtt = this.createRecord('JournalTaskType', {
      title: taskType.title,
      kind: taskType.kind
    });
    this.addHasMany(journal, [jtt], {
      inverse: 'journal'
    });
    return jtt;
  },
  createTaskTemplate: function(journal, phase_template, jtt) {
    return this.createRecord('TaskTemplate', {
      phase_template: phase_template
    });
  },
  createJournalOldRole: function(journal, oldRoleAttrs) {
    var oldRole;
    if (oldRoleAttrs == null) {
      oldRoleAttrs = {};
    }
    oldRole = this.createRecord('OldRole', oldRoleAttrs);
    this.addHasMany(journal, [oldRole], {
      inverse: 'journal'
    });
    return oldRole;
  }
};

FactoryAttributes = {};

FactoryAttributes.User = {
  _rootKey: 'user',
  id: null,
  full_name: 'Fake User',
  avatar_url: '/images/profile-no-image.png',
  username: 'fakeuser',
  email: 'fakeuser@example.com',
  siteAdmin: false,
  affiliation_ids: []
};

FactoryAttributes.Journal = {
  _rootKey: 'journal',
  id: null,
  name: 'Fake Journal',
  logo_url: '/images/no-journal-image.gif',
  paper_types: ['Research'],
  journal_task_type_ids: [],
  manuscript_manager_template_ids: [],
  old_role_ids: [],
  manuscript_css: null,
  doi_publisher_prefix: null,
  doi_journal_prefix: null,
  last_doi_issued: null
};

FactoryAttributes.AdminJournal = {
  _rootKey: 'admin_journal',
  id: null,
  name: 'Fake Journal',
  logo_url: '/images/no-journal-image.gif',
  paper_types: ['Research'],
  journal_task_type_ids: [],
  manuscript_manager_template_ids: [],
  old_role_ids: [],
  manuscript_css: null,
  doi_publisher_prefix: null,
  doi_journal_prefix: null,
  last_doi_issued: null
};

FactoryAttributes.OldRole = {
  _rootKey: 'old_role',
  id: null,
  name: null,
  kind: null,
  required: true,
  can_administer_journal: false,
  can_view_assigned_manuscript_managers: false,
  can_view_all_manuscript_managers: false,
  journal_id: null
};

FactoryAttributes.Author = {
  _rootKey: 'author',
  id: null,
  first_name: 'Dave',
  last_name: 'Thomas',
  paper_id: null,
  position: 1
};

FactoryAttributes.Paper = {
  _rootKey: 'paper',
  id: 1,
  short_title: 'Paper',
  title: 'Foo',
  body: null,
  publishing_state: 'submitted',
  paper_type: 'Research',
  status: null,
  phase_ids: [],
  figure_ids: [],
  author_ids: [],
  supporting_information_file_ids: [],
  assignee_ids: [],
  editor_ids: [],
  reviewer_ids: [],
  tasks: [],
  journal_id: null
};

FactoryAttributes.LitePaper = {
  _rootKey: 'paper',
  id: null,
  title: 'Foo',
  paper_id: null,
  short_title: 'Paper',
  publishing_state: 'submitted',
  oldRoles: []
};

FactoryAttributes.MessageTask = {
  _rootKey: 'task',
  id: null,
  title: 'Message Time',
  type: 'MessageTask',
  completed: false,
  body: [],
  paper_title: 'Foo',
  oldRole: 'author',
  phase_id: null,
  paper_id: null,
  lite_paper_id: null,
  assignee_ids: [],
  participant_ids: [],
  comment_ids: []
};

FactoryAttributes.Task = {
  _rootKey: 'task',
  id: null,
  title: 'Base Task',
  type: 'Task',
  completed: false,
  body: [],
  paper_title: 'Foo',
  oldRole: 'admin',
  phase_id: null,
  paper_id: null,
  lite_paper_id: null,
  assignee_ids: [],
  assigned_to_me: true,
  participant_ids: [],
  comment_ids: []
};

FactoryAttributes.AdHocTask = {
  _rootKey: 'ad_hoc_task',
  id: null,
  title: 'AdHoc Task',
  type: 'AdHocTask',
  completed: false,
  body: [],
  paper_title: 'Foo',
  oldRole: 'user',
  phase_id: null,
  paper_id: null,
  lite_paper_id: null,
  assignee_ids: [],
  assigned_to_me: true,
  participant_ids: [],
  comment_ids: []
};

FactoryAttributes.ReviewerReportTask = {
  _rootKey: 'task',
  id: null,
  title: 'Reviewer Report by Reviewer User',
  type: 'ReviewerReportTask',
  completed: false,
  body: [],
  paper_title: 'Foo',
  old_role: 'reviewer',
  phase_id: null,
  paper_id: null,
  lite_paper_id: null,
  assignee_ids: [],
  participant_ids: [],
  comment_ids: []
};

FactoryAttributes.FrontMatterReviewerReportTask = {
  _rootKey: 'task',
  id: null,
  title: 'Front Matter Reviewer Report by Reviewer User',
  type: 'FrontMatterReviewerReportTask',
  completed: false,
  body: [],
  paper_title: 'Foo',
  old_role: 'reviewer',
  phase_id: null,
  paper_id: null,
  lite_paper_id: null,
  assignee_ids: [],
  participant_ids: [],
  comment_ids: []
};

FactoryAttributes.ReviseTask = {
  _rootKey: 'task',
  id: null,
  title: 'Revise Task',
  type: 'ReviseTask',
  completed: false,
  body: [],
  paper_title: 'Foo',
  old_role: 'admin',
  phase_id: null,
  paper_id: null,
  lite_paper_id: null,
  assignee_ids: [],
  participant_ids: [],
  comment_ids: []
};

FactoryAttributes.BillingTask = {
  _rootKey: 'task',
  id: null,
  title: 'Billing',
  type: 'BillingTask',
  completed: false,
  body: [],
  paper_title: 'Foo',
  old_role: 'admin',
  phase_id: null,
  paper_id: null,
  lite_paper_id: null,
  assignee_ids: [],
  participant_ids: [],
  comment_ids: [],
  assigned_to_me: true,
  is_metadata_task: false,
  is_submission_task: true
};

FactoryAttributes.FigureTask = {
  _rootKey: 'task',
  id: null,
  title: 'Figures',
  type: 'FigureTask',
  completed: false,
  body: [],
  paper_title: 'Foo',
  old_role: 'admin',
  phase_id: null,
  paper_id: null,
  lite_paper_id: null,
  assignee_ids: [],
  participant_ids: [],
  comment_ids: [],
  is_metadata_task: true,
  is_submission_task: true
};

FactoryAttributes.FinancialDisclosureTask = {
  _rootKey: 'task',
  body: [],
  assigned_to_me: true,
  comment_ids: [],
  completed: false,
  funder_ids: [],
  id: null,
  lite_paper_id: null,
  paper_id: null,
  paper_title: 'Test',
  participation_ids: [],
  phase_id: null,
  question_ids: [],
  old_role: 'author',
  title: 'Financial Disclosure',
  type: 'FinancialDisclosureTask'
};

FactoryAttributes.Funder = {
  _rootKey: 'funder',
  author_ids: [],
  funder_had_influence: false,
  funder_influence_description: null,
  grant_number: null,
  id: null,
  name: 'Monsanto',
  task_id: null,
  website: 'www.monsanto.com'
};

FactoryAttributes.ReportingGuidelinesTask = {
  _rootKey: 'task',
  body: null,
  comment_ids: [],
  completed: false,
  id: null,
  lite_paper_id: null,
  paper_id: null,
  paper_title: 'Test',
  participation_ids: [],
  phase_id: null,
  question_ids: [],
  assigned_to_me: true,
  old_role: 'author',
  title: 'Reporting Guidelines',
  type: 'ReportingGuidelinesTask'
};

FactoryAttributes.AuthorsTask = {
  _rootKey: 'task',
  body: null,
  comment_ids: [],
  completed: false,
  id: null,
  lite_paper_id: null,
  paper_id: null,
  paper_title: 'Test',
  participation_ids: [],
  phase_id: null,
  question_ids: [],
  assigned_to_me: true,
  old_role: 'author',
  title: 'Authors',
  type: 'AuthorsTask'
};

FactoryAttributes.TitleAndAbstractTask = {
  _rootKey: 'task',
  body: null,
  comment_ids: [],
  completed: false,
  id: null,
  lite_paper_id: null,
  paper_id: null,
  paper_title: 'Test',
  participation_ids: [],
  phase_id: null,
  question_ids: [],
  assigned_to_me: true,
  old_role: 'editor',
  title: 'Title And Abstract',
  type: 'TitleAndAbstractTask'
};

FactoryAttributes.Comment = {
  _rootKey: 'comment',
  id: null,
  commenter_id: null,
  task_id: null,
  body: 'A sample comment',
  created_at: null,
  comment_look_ids: []
};

FactoryAttributes.CommentLook = {
  _rootKey: 'comment_look',
  id: null,
  read_at: null,
  comment_id: null,
  user_id: null
};

FactoryAttributes.Phase = {
  _rootKey: 'phase',
  id: null,
  name: 'Submission Data',
  position: null,
  paper_id: null,
  tasks: []
};

FactoryAttributes.ManuscriptManagerTemplate = {
  _rootKey: 'manuscript_manager_template',
  id: null,
  paper_type: 'Research',
  phase_template_ids: [],
  journal_id: null
};

FactoryAttributes.PhaseTemplate = {
  _rootKey: 'phase_template',
  id: null,
  position: 1,
  manuscript_manager_template_id: null,
  name: 'Phase 1',
  task_template_ids: []
};

FactoryAttributes.JournalTaskType = {
  _rootKey: 'journal_task_type',
  id: null,
  task_type_id: null,
  title: null,
  journal_id: null,
  old_role: null
};

FactoryAttributes.TaskTemplate = {
  _rootKey: 'task_template',
  id: null,
  template: [],
  title: 'Journal Task Template',
  phase_template_id: null,
  journal_task_type_id: null
};

FactoryAttributes.TaskType = {
  _rootKey: 'task_type',
  id: null,
  kind: 'Task'
};

FactoryAttributes.Participation = {
  _rootKey: 'participation',
  id: null,
  task: null,
  participant_id: null
};

FactoryAttributes.Collaboration = {
  _rootKey: 'collaboration',
  id: null,
  paper_id: null,
  user_id: null
};

FactoryAttributes.NestedQuestion = {
  _rootKey: 'nested_question',
  id: null,
  owner: {
    owner_id: null,
    owner_type: null
  },
  ident: 'some_ident',
  parent_id: null,
  value_type: 'text'
};

export default Factory;
