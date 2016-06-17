import Ember from 'ember';
import DS from 'ember-data';
import startApp from '../helpers/start-app';
import { test, moduleFor } from 'ember-qunit';
var container, subject;

subject = null;

container = null;

module('integration/serializer', {
  beforeEach: function() {
    var app;
    app = startApp();
    container = app.__container__;
    return subject = container.lookup('serializer:application');
  }
});

test('normalizeTaskName denamespaces task types', function(assert) {
  var result;
  result = subject.normalizeTaskName('Foo::BarTask');
  return assert.equal(result, 'BarTask', 'strips the namespace off the type');
});

test('normalizeTaskName doesnt touch unnamespaced stuff', function(assert) {
  var result;
  result = subject.normalizeTaskName('Task');
  return assert.equal(result, 'Task', 'Task goes through unchanged');
});

test('normalizeTaskName denamespaces deeply namespaced task types', function(assert) {
  var result;
  result = subject.normalizeTaskName('Foo::Baz::BarTask');
  return assert.equal(result, 'BarTask', 'strips the namespace off the type');
});

test('normalizeTaskName denamespaces really deeply namespaced task types', function(assert) {
  var result;
  result = subject.normalizeTaskName('Tahi::Foo::Baz::BarTask');
  return assert.equal(result, 'BarTask', 'strips the namespace off the type');
});

test('serializing a model that was originally namespaced will correctly re-namespace it', function(assert) {
  return Ember.run((function(_this) {
    return function() {
      var json, snapshot, task;
      task = getStore().createRecord('task', {
        qualifiedType: 'Foo::BarTask'
      });
      snapshot = task._createSnapshot();
      json = subject.serialize(snapshot);
      assert.equal(json.type, 'Foo::BarTask');
      return assert.equal(void 0, json.qualified_type, 'deletes qualified_type from the payload');
    };
  })(this));
});

test('mungeTaskData', function(assert) {
  var payload;
  payload = subject.mungeTaskData({
    type: 'bar'
  });
  return assert.equal(payload.qualified_type, 'bar', 'sets qualified type');
});

test("normalizeSingleResponse normalizes the primary task record based on its 'type' attribute", function(assert) {
  var expectedPayload, pluralResult, result, store, task;
  store = getStore();
  task = {
    id: '1',
    type: 'InitialTechCheckTask',
    title: 'Initial Tech Check'
  };
  expectedPayload = {
    "attributes": {
      "qualifiedType": "InitialTechCheckTask",
      "title": "Initial Tech Check",
      "type": "InitialTechCheckTask"
    },
    "id": "1",
    "relationships": {},
    "type": "initial-tech-check-task"
  };
  result = subject.normalizeSingleResponse(store, store.modelFor('task'), {
    task: task
  });
  assert.deepEqual(result.data, expectedPayload, 'primary task record is normalized based on its type');
  pluralResult = subject.normalizeSingleResponse(store, store.modelFor('task'), {
    tasks: [task]
  });
  return assert.deepEqual(pluralResult.data, expectedPayload, 'normalizes a 1-length array of tasks too');
});

test("normalizeSingleResponse leaves a task with type 'Task' unchanged", function(assert) {
  var expectedPayload, pluralResult, result, store, task;
  store = getStore();
  task = {
    id: '1',
    type: 'Task',
    title: 'Ad-hoc Task'
  };
  expectedPayload = {
    "attributes": {
      "qualifiedType": "Task",
      "title": "Ad-hoc Task",
      "type": "Task"
    },
    "id": "1",
    "relationships": {},
    "type": "task"
  };
  result = subject.normalizeSingleResponse(store, store.modelFor('task'), {
    task: task
  });
  assert.deepEqual(result.data, expectedPayload, 'primary task record is normalized based on its type');
  pluralResult = subject.normalizeSingleResponse(store, store.modelFor('task'), {
    tasks: [task]
  });
  return assert.deepEqual(pluralResult.data, expectedPayload, 'normalizes a 1-length array of tasks too');
});

test("normalizeSingleResponse normalizes sideloaded tasks via their 'type' attribute", function(assert) {
  var jsonHash, result, store;
  store = getStore();
  jsonHash = {
    tasks: [
      {
        id: '1',
        type: 'Standard::InitialTechCheckTask',
        title: 'Initial Tech Check'
      }, {
        id: '2',
        type: 'Task',
        title: 'Ad-hoc'
      }
    ],
    phase: {
      id: '1',
      tasks: [
        {
          id: '1',
          type: 'InitialTechCheckTask'
        }, {
          id: '2',
          type: 'Task'
        }
      ]
    }
  };
  result = subject.normalizeSingleResponse(store, store.modelFor('phase'), jsonHash);
  assert.deepEqual(result.data, {
    "attributes": {},
    "id": "1",
    "relationships": {
      "tasks": {
        "data": [
          {
            "id": "1",
            "type": "initial-tech-check-task"
          }, {
            "id": "2",
            "type": "task"
          }
        ]
      }
    },
    "type": "phase"
  }, "primary record is serialized into data");
  return assert.deepEqual(result.included, [
    {
      "attributes": {
        "qualifiedType": "Task",
        "title": "Ad-hoc",
        "type": "Task"
      },
      "id": "2",
      "relationships": {},
      "type": "task"
    }, {
      "attributes": {
        "qualifiedType": "Standard::InitialTechCheckTask",
        "title": "Initial Tech Check",
        "type": "InitialTechCheckTask"
      },
      "id": "1",
      "relationships": {},
      "type": "initial-tech-check-task"
    }
  ], 'tasks are sideloaded with their proper type, defaulting to adhoc');
});

test("mungePayloadTypes", function(assert) {
  var expected, inputPayload, output;
  inputPayload = {
    tasks: [
      {
        id: 1,
        type: 'NameSpace::AuthorTask'
      }, {
        id: 2,
        type: 'SomeTaskName'
      }, {
        id: 3
      }
    ],
    others: [
      {
        id: 4,
        type: 'OtherStuff::Other'
      }
    ]
  };
  output = subject.mungePayloadTypes(inputPayload);
  expected = {
    tasks: [
      {
        id: 1,
        qualified_type: 'NameSpace::AuthorTask',
        type: 'AuthorTask'
      }, {
        id: 2,
        qualified_type: 'SomeTaskName',
        type: 'SomeTaskName'
      }, {
        id: 3
      }
    ],
    others: [
      {
        id: 4,
        qualified_type: 'OtherStuff::Other',
        type: 'Other'
      }
    ]
  };
  return assert.deepEqual(expected, output, 'It munges every object with a type, but leaves objects without types untouched');
});

test("newNormalize when the primary record has the same type attribute as the passed-in modelName", function(assert) {
  var newModelName, payload, ref, ref1, simplePayload, singularPayload;
  simplePayload = {
    tasks: [
      {
        id: 1,
        type: 'Task'
      }
    ]
  };
  ref = subject.newNormalize('task', simplePayload), newModelName = ref.newModelName, payload = ref.payload;
  assert.equal(newModelName, 'task', 'modelName is unchanged when the model name is the same as the type');
  assert.deepEqual(payload, simplePayload, 'payload is also unchanged');
  singularPayload = {
    task: {
      id: 1,
      type: 'Task'
    }
  };
  ref1 = subject.newNormalize('task', singularPayload), newModelName = ref1.newModelName, payload = ref1.payload;
  assert.equal(newModelName, 'task', 'modelName is unchanged when the model name is the same as the type');
  return assert.deepEqual(payload, {
    tasks: [
      {
        id: 1,
        type: 'Task'
      }
    ]
  }, 'singular primary key is pluralized');
});

test("newNormalize always pluralizes the primary record's key, even when the primary record has no type attribute", function(assert) {
  var newModelName, payload, ref, ref1, simplePayload, singularPayload;
  simplePayload = {
    tasks: [
      {
        id: 1
      }
    ]
  };
  ref = subject.newNormalize('task', simplePayload), newModelName = ref.newModelName, payload = ref.payload;
  assert.equal(newModelName, 'task', 'modelName is unchanged');
  assert.deepEqual(payload, simplePayload, 'payload is also unchanged');
  singularPayload = {
    task: {
      id: 1
    }
  };
  ref1 = subject.newNormalize('task', singularPayload), newModelName = ref1.newModelName, payload = ref1.payload;
  assert.equal(newModelName, 'task', 'model name is unchanged for singular payloads too');
  return assert.deepEqual(payload, {
    tasks: [
      {
        id: 1
      }
    ]
  }, 'singular primary key has been pluralized');
});

test("newNormalize when the primary record has a different type attribute than the passed-in modelName", function(assert) {
  var newModelName, payload, payloadToChange, ref, ref1;
  payloadToChange = {
    tasks: [
      {
        id: 1,
        type: 'AuthorTask'
      }
    ]
  };
  ref = subject.newNormalize('task', payloadToChange), newModelName = ref.newModelName, payload = ref.payload;
  assert.equal(newModelName, 'author-task', 'since the primary record had a type, the model name is changed to that type (and dasherized)');
  assert.deepEqual(payload, {
    'author_tasks': [
      {
        id: 1,
        type: 'AuthorTask'
      }
    ]
  }, 'model is moved to correct primary key');
  payloadToChange = {
    task: {
      id: 1,
      type: 'AuthorTask'
    }
  };
  ref1 = subject.newNormalize('task', payloadToChange), newModelName = ref1.newModelName, payload = ref1.payload;
  assert.equal(newModelName, 'author-task', 'model type is corrected for singular payloads too');
  return assert.deepEqual(payload, {
    'author_tasks': [
      {
        id: 1,
        type: 'AuthorTask'
      }
    ]
  }, 'model is moved to correct primary key for singular payloads');
});

test("newNormalize puts non-primary records into new buckets based on their type attributes", function(assert) {
  var newModelName, payload, payloadToChange, ref;
  payloadToChange = {
    papers: [
      {
        id: 1
      }
    ],
    tasks: [
      {
        id: 2,
        type: 'AuthorTask'
      }
    ]
  };
  ref = subject.newNormalize('paper', payloadToChange), newModelName = ref.newModelName, payload = ref.payload;
  assert.equal(newModelName, 'paper', 'primary record type is still paper');
  return assert.deepEqual(payload, {
    'author_tasks': [
      {
        id: 2,
        type: 'AuthorTask'
      }
    ],
    papers: [
      {
        id: 1
      }
    ]
  }, 'side loaded model is moved to correct primary key');
});

test("newNormalize doesn't touch non-primary records that don't have a type attributes", function(assert) {
  var newModelName, payload, payloadToChange, ref;
  payloadToChange = {
    papers: [
      {
        id: 1
      }
    ],
    tasks: [
      {
        id: 2
      }
    ]
  };
  ref = subject.newNormalize('paper', payloadToChange), newModelName = ref.newModelName, payload = ref.payload;
  assert.equal(newModelName, 'paper', 'primary record type is still paper');
  return assert.deepEqual(payload, {
    tasks: [
      {
        id: 2
      }
    ],
    papers: [
      {
        id: 1
      }
    ]
  }, 'side loaded model is unchanged');
});

test("normalizeSingleResponse normalizes sideloaded stuff even if they're not explicitly tasks", function(assert) {
  var jsonHash, result, store;
  store = getStore();
  jsonHash = {
    tasks: [
      {
        id: '2',
        type: 'Task',
        title: 'Ad-hoc'
      }
    ],
    initial_tech_check_tasks: [
      {
        id: '1',
        type: 'Standard::InitialTechCheckTask',
        title: 'Initial Tech Check'
      }
    ],
    phase: {
      id: '1',
      tasks: [
        {
          id: '1',
          type: 'InitialTechCheckTask'
        }, {
          id: '2',
          type: 'Task'
        }
      ]
    }
  };
  result = subject.normalizeSingleResponse(store, store.modelFor('phase'), jsonHash);
  assert.deepEqual(result.data, {
    "attributes": {},
    "id": "1",
    "relationships": {
      "tasks": {
        "data": [
          {
            "id": "1",
            "type": "initial-tech-check-task"
          }, {
            "id": "2",
            "type": "task"
          }
        ]
      }
    },
    "type": "phase"
  }, "primary record is serialized into data");
  return assert.deepEqual(result.included, [
    {
      "attributes": {
        "qualifiedType": "Task",
        "title": "Ad-hoc",
        "type": "Task"
      },
      "id": "2",
      "relationships": {},
      "type": "task"
    }, {
      "attributes": {
        "qualifiedType": "Standard::InitialTechCheckTask",
        "title": "Initial Tech Check",
        "type": "InitialTechCheckTask"
      },
      "id": "1",
      "relationships": {},
      "type": "initial-tech-check-task"
    }
  ], 'tasks are sideloaded with their proper type, defaulting to adhoc');
});

test("normalizeArrayResponse normalizes an array of tasks via each task's type attribute", function(assert) {
  var jsonHash, result, store;
  store = getStore();
  jsonHash = {
    tasks: [
      {
        id: '1',
        type: 'Tahi::InitialTechCheckTask',
        title: 'Initial Tech Check'
      }, {
        id: '2',
        type: 'Other::AuthorsTask',
        title: 'Author'
      }, {
        id: '3',
        type: 'Task',
        title: 'Ad-hoc'
      }
    ]
  };
  result = subject.normalizeArrayResponse(store, store.modelFor('task'), jsonHash);
  assert.equal(result.data.length, 3, 'All three tasks are included in data');
  assert.ok(result.data.findBy('type', 'task'), 'the base task type is included');
  assert.ok(result.data.findBy('type', 'initial-tech-check-task'), 'initial-tech-check-task found');
  assert.ok(result.data.findBy('type', 'authors-task'), 'author-task found');
});

test("normalizeArrayResponse properly denamespaces tasks even when the main type isn't 'task'", function(assert) {
  var jsonHash, result, store;
  store = getStore();
  jsonHash = {
    paper: {},
    authors_tasks: [
      {
        id: '2',
        type: 'NameSpace::AuthorsTask',
        title: 'Author'
      }
    ]
  };
  result = subject.normalizeArrayResponse(store, store.modelFor('paper'), jsonHash);
  assert.equal(result.included[0].type, 'authors-task');
});

test("normalizeArrayResponse works correctly even when no 'task' type tasks are in the payload", function(assert) {
  var jsonHash, result, store;
  store = getStore();
  jsonHash = {
    tasks: [
      {
        id: '1',
        type: 'InitialTechCheckTask',
        title: 'Initial Tech Check'
      }, {
        id: '2',
        type: 'AuthorsTask',
        title: 'Author'
      }
    ]
  };
  result = subject.normalizeArrayResponse(store, store.modelFor('task'), jsonHash);
  assert.equal(result.data.length, 2, 'Tasks have been put into data');
  assert.ok(result.data.findBy('type', 'initial-tech-check-task'), 'initial-tech-check-task found');
  assert.ok(result.data.findBy('type', 'authors-task'), 'author-task found');
});

test("normalizeArrayResponse works correctly even when no 'task' type tasks are in the payload", function(assert) {
  var jsonHash, result, store;
  store = getStore();
  jsonHash = {
    attachments: [
      {
        id: '1',
        type: 'AdhocAttachment'
      }
    ]
  };
  result = subject.normalizeArrayResponse(store, store.modelFor('adhoc-attachment'), jsonHash);
  let expected = {
    data: [
      {
        id: "1",
        attributes: {},
        relationships: {},
        type: "adhoc-attachment"
      }
    ],
    included: []
  };
  assert.deepEqual(result, expected, 'found adhoc-attachment in data')
});

test("normalizePayload reorganizes a JSON payload according to the items' types", function(assert) {
  var jsonHash, result, store;
  store = getStore();
  jsonHash = {
    paper: { id: '99' },
    attachment: { id: '44', type: 'AdhocAttachment' },
    tasks: [
      { id: '1', type: 'InitialTechCheckTask' },
      { id: '2', type: 'AuthorsTask' },
      { id: '3' }
    ]
  };
  expectedOutput = {
    papers: [{ id: '99' }],
    adhoc_attachments: [{ id: '44', type: 'AdhocAttachment' }],
    authors_tasks: [{ id: '2', type: 'AuthorsTask' }],
    initial_tech_check_tasks: [ { id: '1', type: 'InitialTechCheckTask' } ],
    tasks: [{ id: '3'}]
  };
  result = subject.normalizePayload(jsonHash);
  assert.deepEqual(result, expectedOutput);
});
