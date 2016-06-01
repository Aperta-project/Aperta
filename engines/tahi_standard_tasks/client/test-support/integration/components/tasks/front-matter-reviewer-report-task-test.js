import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from '../../../helpers/start-app';
import { paperWithTask, addUserAsParticipant, addNestedQuestionsToTask }
  from '../../../helpers/setups';
import setupMockServer from '../../../helpers/mock-server';
import Factory from '../../../helpers/factory';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

var app, currentPaper, fakeUser, frontMatterReviewerReportTask,
    taskId, paperPayload, server;

app = null;
server = null;
fakeUser = null;
currentPaper = null;
taskId = 94139;
frontMatterReviewerReportTask = null;
paperPayload = null;

module('Integration: Front Matter Reviewer Report', {
  teardown: function() {
    server.restore();
    return Ember.run(app, app.destroy);
  },

  setup: function() {
    var journal, mirrorCreateResponse, paperResponse,
        phase, records, taskPayload;
    app = startApp();
    server = setupMockServer();
    fakeUser = window.currentUserData.user;
    TestHelper.handleFindAll('discussion-topic', 1);

    records = paperWithTask('FrontMatterReviewerReportTask', {
      id: taskId,
      title: 'Front Matter Reviewer Report by Bob Jones',
      oldRole: 'reviewer'
    });

    currentPaper = records[0];
    frontMatterReviewerReportTask = records[1];
    journal = records[2];
    phase = records[3];

    paperPayload = Factory.createPayload('paper');
    paperPayload.addRecords(records.concat([fakeUser]));
    paperResponse = paperPayload.toJSON();
    paperResponse.participations =
      [addUserAsParticipant(frontMatterReviewerReportTask, fakeUser)];

    taskPayload = Factory.createPayload('task');

    var nestedQuestions;
    nestedQuestions = [
      Factory.createRecord('NestedQuestion', {
        ident: 'front_matter_reviewer_report--decision_term'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'front_matter_reviewer_report--competing_interests'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'front_matter_reviewer_report--suitable'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'front_matter_reviewer_report--suitable--comment'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'front_matter_reviewer_report--includes_unpublished_data'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'front_matter_reviewer_report--includes_unpublished_data--explanation'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'front_matter_reviewer_report--additional_comments'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'front_matter_reviewer_report--identity'
      })
    ];

    addNestedQuestionsToTask(nestedQuestions, frontMatterReviewerReportTask);
    var nestedQuestionsPayload = Factory.createPayload('nested_questions');
    nestedQuestionsPayload.addRecords(nestedQuestions);
    taskPayload.addRecords([frontMatterReviewerReportTask, fakeUser]);
    frontMatterReviewerReportTask = taskPayload.toJSON();

    var tasksPayload = Factory.createPayload('tasks');
    tasksPayload.addRecords([frontMatterReviewerReportTask]);

    server.respondWith('GET', '/api/journals', [
      403, {
        'Content-Type': 'application/json'
      }, JSON.stringify({})
    ]);

    server.respondWith('GET', '/api/papers/' + currentPaper.id,
      [ 200, { 'Content-Type': 'application/json' },
        JSON.stringify(paperResponse) ]
    );

    server.respondWith('GET', '/api/papers/' + currentPaper.id + '/tasks',
      [ 200, { 'Content-Type': 'application/json' },
      JSON.stringify(tasksPayload.toJSON()) ]
    );

    server.respondWith('GET',
      '/api/tasks/' + taskId + '/nested_questions',
      [ 200, { 'Content-Type': 'application/json' },
        JSON.stringify(nestedQuestionsPayload.toJSON())]
    );

    server.respondWith('GET',
      '/api/tasks/' + taskId + '/nested_question_answers',
      [ 200, { 'Content-Type': 'application/json' },
        JSON.stringify({nested_question_answers: []})]
    );

    server.respondWith('GET', '/api/tasks/' + taskId,
      [ 200, { 'Content-Type': 'application/json' },
        JSON.stringify(frontMatterReviewerReportTask)]
    );

    server.respondWith('GET', '/api/journals',
      [200, { 'Content-Type': 'application/json' },
      JSON.stringify({journals:[]})]
    );
  }
});

test('Viewing the card', function(assert) {
  const url = '/papers/' + currentPaper.id + '/tasks/' + taskId;
  return visit(url).then(function() {
    assert.equal(
      find('.overlay-body-title').text().trim(),
      'Front Matter Reviewer Report by Bob Jones'
    );
  });
});

test('Readonly mode: Not able to provide reviewer feedback', function(assert) {
  const url = '/papers/' + currentPaper.id + '/tasks/' + taskId;
  Factory.createPermission('FrontMatterReviewerReportTask', taskId, ['view']);
  return visit(url).then(function() {
    assert.elementNotFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=accept]'), 'User cannot provide an accept for publication recommendation');
    assert.elementNotFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=reject]'), 'User cannot provide a reject recommendation');
    assert.elementNotFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=major_revision]'), 'User cannot provide a major revision recommendation');
    assert.elementNotFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=minor_revision]'), 'User cannot provide a minor revision recommendation');

    assert.elementNotFound('textarea[name=front_matter_reviewer_report--competing_interests]'), 'User cannot provide their competing interests statement');

    assert.elementNotFound('textarea[name=front_matter_reviewer_report--competing_interests]'), 'User cannot provide their competing interests statement');

    assert.elementNotFound('input[name*=front_matter_reviewer_report--suitable][type=radio][value=true]'), 'User cannot provide yes response to biology suitability');
    assert.elementNotFound('input[name*=front_matter_reviewer_report--suitable][type=radio][value=false]'), 'User cannot provide no response to biology suitability');
    assert.elementNotFound('textarea[name=front_matter_reviewer_report--suitable--comment]'), 'User cannot provide their review of biology suitability');

    assert.elementNotFound('input[name*=front_matter_reviewer_report--includes_unpublished_data][type=radio][value=true]'), 'User cannot provide respond yes to statistical analysis');
    assert.elementNotFound('input[name*=front_matter_reviewer_report--includes_unpublished_data][type=radio][value=false]'), 'User cannot provide response no to statistical analysis');
    assert.elementNotFound('textarea[name=front_matter_reviewer_report--includes_unpublished_data--explanation]'), 'User cannot provide their review of statistical analysis');

    assert.elementNotFound('textarea[name=front_matter_reviewer_report--additional_comments]'), 'User cannot provide additional comments');

    assert.elementNotFound('textarea[name=front_matter_reviewer_report--identity]'), 'User cannot provide their identity');
  });
});


test('Edit mode: Providing reviewer feedback', function(assert) {
  const url = '/papers/' + currentPaper.id + '/tasks/' + taskId;
  Factory.createPermission('FrontMatterReviewerReportTask', taskId, ['edit']);
  return visit(url).then(function() {
    assert.elementFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=accept]'), 'User can provide an accept for publication recommendation');
    assert.elementFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=reject]'), 'User can provide a reject recommendation');
    assert.elementFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=major_revision]'), 'User can provide a major revision recommendation');
    assert.elementFound('input[name*=front_matter_reviewer_report--decision_term][type=radio][value=minor_revision]'), 'User can provide a minor revision recommendation');

    assert.elementFound('textarea[name=front_matter_reviewer_report--competing_interests]'), 'User can provide their competing interests statement');

    assert.elementFound('textarea[name=front_matter_reviewer_report--competing_interests]'), 'User can provide their competing interests statement');

    assert.elementFound('input[name*=front_matter_reviewer_report--suitable][type=radio][value=true]'), 'User can respond yes to biology suitability');
    assert.elementFound('input[name*=front_matter_reviewer_report--suitable][type=radio][value=false]'), 'User can respond no to biology suitability');
    assert.elementFound('textarea[name=front_matter_reviewer_report--suitable--comment]'), 'User can provide their review of biology suitability');

    assert.elementFound('input[name*=front_matter_reviewer_report--includes_unpublished_data][type=radio][value=true]'), 'User can provide respond yes to statistical analysis');
    assert.elementFound('input[name*=front_matter_reviewer_report--includes_unpublished_data][type=radio][value=false]'), 'User can provide response no to statistical analysis');
    assert.elementFound('textarea[name=front_matter_reviewer_report--includes_unpublished_data--explanation]'), 'User can provide their review of statistical analysis');

    assert.elementFound('textarea[name=front_matter_reviewer_report--additional_comments]'), 'User can provide additional comments');

    assert.elementFound('textarea[name=front_matter_reviewer_report--identity]'), 'User can provide their identity');
  });
});
