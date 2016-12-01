import { test } from 'ember-qunit';
import TestHelper, { mockTeardown } from 'ember-data-factory-guy/factory-guy-test-helper';
import Factory from '../helpers/factory';
import setupMockServer from '../helpers/mock-server';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';
import {
  paperWithTask, addUserAsParticipant, addNestedQuestionToTask
} from '../helpers/setups';

let fakeUser = null;
let server   = null;
let paperId  = null;
const taskId = 90210;

const openNewAuthorForm = function() {
  click('#add-new-author-button');
  click('#add-new-individual-author-link');
};

moduleForAcceptance('Integration: adding an author', {
  afterEach() {
    window.RailsEnv.orcidConnectEnabled = false;
    server.restore();
    mockTeardown();
  },

  beforeEach() {
    window.RailsEnv.orcidConnectEnabled = false;
    fakeUser = window.currentUserData.user;
    server   = setupMockServer();

    const records = paperWithTask('AuthorsTask', {
      id: taskId
    });

    Factory.createPermission('AuthorsTask', taskId, ['edit']);
    TestHelper.mockFindAll('discussion-topic', 1);

    const task = records[1];

    // -- Paper Setup

    const paperPayload = Factory.createPayload('paper');
    let paper = paperPayload.createRecord('Paper', {id: 1});
    paperId = paper.id;
    paperPayload.addRecords(records.concat([fakeUser]));
    const paperResponse = paperPayload.toJSON();
    paperResponse.participations = [addUserAsParticipant(task, fakeUser)];

    server.respondWith('GET', '/api/papers/' + paperId, [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(paperResponse)
    ]);

    // -- Task Setup

    const taskPayload = Factory.createPayload('task');
    taskPayload.addRecords([task, fakeUser]);

    server.respondWith('GET', '/api/tasks/' + taskId, [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(taskPayload.toJSON())
    ]);

    // -- Nested Question Setup

    const authorResponse = {
      nested_questions: [
        {id: 1,  text: 'Q', value_type: 'boolean',      ident: 'author--published_as_corresponding_author' },
        {id: 2,  text: 'Q', value_type: 'boolean',      ident: 'author--deceased' },
        {id: 3,  text: 'C', value_type: 'question-set', ident: 'author--contributions' },
        {id: 4,  text: 'Q', value_type: 'boolean',      ident: 'author--contributions--conceptualization' },
        {id: 5,  text: 'Q', value_type: 'boolean',      ident: 'author--contributions--investigation' },
        {id: 6,  text: 'Q', value_type: 'boolean',      ident: 'author--contributions--visualization' },
        {id: 7,  text: 'Q', value_type: 'boolean',      ident: 'author--contributions--methodology' },
        {id: 8,  text: 'Q', value_type: 'boolean',      ident: 'author--contributions--resources' },
        {id: 9,  text: 'Q', value_type: 'boolean',      ident: 'author--contributions--supervision' },
        {id: 10, text: 'Q', value_type: 'boolean',      ident: 'author--contributions--software' },
        {id: 11, text: 'Q', value_type: 'boolean',      ident: 'author--contributions--data-curation' },
        {id: 12, text: 'Q', value_type: 'boolean',      ident: 'author--contributions--project-administration' },
        {id: 13, text: 'Q', value_type: 'boolean',      ident: 'author--contributions--validation' },
        {id: 14, text: 'Q', value_type: 'boolean',      ident: 'author--contributions--writing-original-draft' },
        {id: 15, text: 'Q', value_type: 'boolean',      ident: 'author--contributions--writing-review-and-editing' },
        {id: 16, text: 'Q', value_type: 'boolean',      ident: 'author--contributions--funding-acquisition' },
        {id: 17, text: 'Q', value_type: 'boolean',      ident: 'author--contributions--formal-analysis' },
        {id: 18, text: 'Q', value_type: 'boolean',      ident: 'author--government-employee' }
      ]
    };

    server.respondWith('GET', '/api/nested_questions?type=Author', [
      200, { 'Content-Type': 'application/json' }, JSON.stringify(authorResponse)
    ]);

    const taskNestedQuestions = [];
    taskNestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 19, ident: 'authors--persons_agreed_to_be_named',     text: 'Whatever' }));
    taskNestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 20, ident: 'authors--authors_confirm_icmje_criteria', text: 'Whatever' }));
    taskNestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 21, ident: 'authors--authors_agree_to_submission',    text: 'Whatever' }));
    _.each(taskNestedQuestions, function(q) {
      addNestedQuestionToTask(q, task);
    });

    server.respondWith('GET', '/api/tasks/' + taskId + '/nested_questions', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify({ nested_questions: taskNestedQuestions })
    ]);

    server.respondWith('GET', '/api/tasks/' + taskId + '/nested_question_answers', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify({nested_question_answers: []})
    ]);

    server.respondWith('GET', '/api/admin/journals/authorization', [204, { 'Content-Type': 'application/json' }, '' ]);
    server.respondWith('GET', '/api/affiliations', [200, { 'Content-Type': 'application/json' }, JSON.stringify([]) ]);
    server.respondWith('GET', '/api/journals', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify({journals:[]})
    ]);

    server.respondWith('POST', '/api/authors', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify({authors: [{id: 5, first_name: 'James', paper_id: paperId, user_id: 1}]})
    ]);

    server.respondWith('GET', '/api/countries', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify({countries:['Columbia']})
    ]);
  }
});

test('can add a new author', function(assert) {
  const firstName = 'James';

  visit(`/papers/${paperId}/tasks/${taskId}`);
  openNewAuthorForm();
  fillIn('.author-first', firstName);
  click('.author-form-buttons .button-secondary:contains("done")');

  andThen(function() {
    assert.ok(
      find(`.author-task-item .author-name:contains('${firstName}')`).length,
          'New author item displays author name'
    );
  });
});

test('validation works', function(assert) {
  window.RailsEnv.orcidConnectEnabled = true;
  visit(`/papers/${paperId}/tasks/${taskId}`);
  openNewAuthorForm();
  click('.author-form-buttons .button-secondary:contains("done")');
  click('.author-task-item-view-text');
  click('.author-form-buttons .button-secondary:contains("done")');

  andThen(function() {
    assert.elementFound(
      '.orcid-connect.error',
      'orcid connect error'
    );
    assert.elementFound(
      '[data-test-id="author-last-name"].error',
      'presence error on last name'
    );
    assert.elementFound(
      '[data-test-id="author-initial"].error',
      'presence error on initial'
    );
    assert.elementFound(
      '[data-test-id="author-email"].error',
      'presence error on email'
    );
    assert.elementFound(
      '[data-test-id="author-affiliation"].error',
      'presence error on affiliation'
    );
    assert.elementFound(
      '[data-test-id="author-government"] .error-message:visible',
      'presence error on government'
    );
  });
});

test('orcid validation does not fire', function(assert) {
  window.RailsEnv.orcidConnectEnabled = false;
  visit(`/papers/${paperId}/tasks/${taskId}`);
  openNewAuthorForm();
  click('.author-form-buttons .button-secondary:contains("done")');
  click('.author-task-item-view-text');
  click('.author-form-buttons .button-secondary:contains("done")');

  andThen(function() {
    assert.elementNotFound(
      '.orcid-connect.error',
      'orcid connect error'
    );
  });
});
