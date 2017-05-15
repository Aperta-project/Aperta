import { test } from 'ember-qunit';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import Factory from '../helpers/factory';
import setupMockServer from '../helpers/mock-server';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';
import {
  paperWithTask, addUserAsParticipant, addNestedQuestionToTask
} from '../helpers/setups';

let fakeUser = null;
let server   = null;
let paperShortDoi  = null;
const taskId = 90210;

const openNewAuthorForm = function() {
  click('#add-new-author-button');
  click('#add-new-individual-author-link');
};

moduleForAcceptance('Integration: adding an author', {
  afterEach() {
    window.RailsEnv.orcidConnectEnabled = false;
    server.restore();
    fakeUser = null;
  },

  beforeEach() {
    window.RailsEnv.orcidConnectEnabled = false;
    fakeUser = window.currentUserData.user;
    server   = setupMockServer();

    const records = paperWithTask('AuthorsTask', {
      id: taskId
    });

    const authorResponse = {
      nested_questions: [
        {id: 1,  text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--published_as_corresponding_author' },
        {id: 2,  text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--deceased' },
        {id: 3,  text: 'C', owner: { id: null, type: 'Author' }, value_type: 'question-set', ident: 'author--contributions' },
        {id: 4,  text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--contributions--conceptualization', owner_id: '3' },
        {id: 5,  text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--contributions--investigation', owner_id: '3' },
        {id: 6,  text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--contributions--visualization', owner_id: '3' },
        {id: 7,  text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--contributions--methodology', owner_id: '3' },
        {id: 8,  text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--contributions--resources', owner_id: '3' },
        {id: 9,  text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--contributions--supervision', owner_id: '3' },
        {id: 10, text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--contributions--software', owner_id: '3' },
        {id: 11, text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--contributions--data-curation', owner_id: '3' },
        {id: 12, text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--contributions--project-administration', owner_id: '3' },
        {id: 13, text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--contributions--validation', owner_id: '3' },
        {id: 14, text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--contributions--writing-original-draft', owner_id: '3' },
        {id: 15, text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--contributions--writing-review-and-editing', owner_id: '3' },
        {id: 16, text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--contributions--funding-acquisition', owner_id: '3' },
        {id: 17, text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--contributions--formal-analysis', owner_id: '3' },
        {id: 18, text: 'Q', owner: { id: null, type: 'Author' }, value_type: 'boolean',      ident: 'author--government-employee' }
      ]
    };

    Factory.createPermission('AuthorsTask', taskId, ['edit']);
    TestHelper.mockFindAll('discussion-topic', 1);

    const task = records.findBy('_rootKey', 'task');

    // -- Paper Setup

    const paperPayload = Factory.createPayload('paper');
    let paper = records[0];
    paper.author_ids = [fakeUser.id];
    paper.creator_id = fakeUser.id;

    paperShortDoi = paper.shortDoi;
    paperPayload.addRecords(records.concat([fakeUser]));
    const paperResponse = paperPayload.toJSON();
    paperResponse.participations = [addUserAsParticipant(task, fakeUser)];

    server.respondWith('GET', '/api/papers/' + paperShortDoi, [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(paperResponse)
    ]);

    // -- Task Setup

    const taskPayload = Factory.createPayload('task');
    taskPayload.addRecords([task, fakeUser]);
    const taskResponse = taskPayload.toJSON();
    taskResponse.nested_questions = [];
    taskResponse.nested_questions.pushObjects(authorResponse.nested_questions);
    taskResponse.authors = [];
    const taskAuthor = _.clone(fakeUser);
    taskAuthor.nested_question_ids = _.map(authorResponse.nested_questions, (q)=> { return q.id; });
    taskAuthor.user_id = fakeUser.id;
    taskResponse.authors.pushObject(taskAuthor);

    server.respondWith('GET', '/api/tasks/' + taskId, [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(taskResponse)
    ]);

    // -- Nested Question Setup

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
      }, JSON.stringify({authors: [{id: 5, first_name: 'James', paper_short_doi: paperShortDoi}]})
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

  visit(`/papers/${paperShortDoi}/tasks/${taskId}`);
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

test('validation works for currentUser/paper creator', function(assert) {
  window.RailsEnv.orcidConnectEnabled = true;
  visit(`/papers/${paperShortDoi}/tasks/${taskId}`);
  click('.task-completed');

  andThen(function() {
    assert.elementFound(
      '.orcid-connect.error',
      'orcid connect error'
    );
    assert.elementFound(
      '[data-test-id="author-initial"].error',
      'presence error on initial'
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

test('validation works for non currentUser/paper creator', function(assert) {
  const authorItem = '.author-task-item:not(.author-task-item-current-user) ';
  window.RailsEnv.orcidConnectEnabled = true;
  visit(`/papers/${paperShortDoi}/tasks/${taskId}`);
  openNewAuthorForm();
  click('.author-form-buttons .button-secondary:contains("done")');
  click(authorItem + '.author-task-item-view-text');
  click('.author-form-buttons .button-secondary:contains("done")');

  andThen(function() {
    assert.elementNotFound(
      authorItem + '.orcid-connect.error',
      'orcid connect error'
    );
    assert.elementFound(
       authorItem + '[data-test-id="author-last-name"].error',
      'presence error on last name'
    );
    assert.elementFound(
       authorItem + '[data-test-id="author-initial"].error',
      'presence error on initial'
    );
    assert.elementFound(
       authorItem + '[data-test-id="author-email"].error',
      'presence error on email'
    );
    assert.elementFound(
       authorItem + '[data-test-id="author-affiliation"].error',
      'presence error on affiliation'
    );
    assert.elementFound(
       authorItem + '[data-test-id="author-government"] .error-message:visible',
      'presence error on government'
    );
  });
});

test('orcid validation does not fire', function(assert) {
  window.RailsEnv.orcidConnectEnabled = false;
  visit(`/papers/${paperShortDoi}/tasks/${taskId}`);
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
