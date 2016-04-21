import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from '../helpers/start-app';
import { paperWithTask, addUserAsParticipant, addNestedQuestionsToTask }
  from '../helpers/setups';
import setupMockServer from '../helpers/mock-server';
import Factory from '../helpers/factory';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

var app, currentPaper, fakeUser, reviewerReportTask,
    taskId, paperPayload, server;

app = null;
server = null;
fakeUser = null;
currentPaper = null;
taskId = 94139;
reviewerReportTask = null;
paperPayload = null;

module('Integration: Reviewer Report', {
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

    records = paperWithTask('ReviewerReportTask', {
      id: taskId,
      title: 'Reviewer Report by Bob Jones',
      oldRole: 'reviewer'
    });

    currentPaper = records[0];
    reviewerReportTask = records[1];
    journal = records[2];
    phase = records[3];

    paperPayload = Factory.createPayload('paper');
    paperPayload.addRecords(records.concat([fakeUser]));
    paperResponse = paperPayload.toJSON();
    paperResponse.participations =
      [addUserAsParticipant(reviewerReportTask, fakeUser)];

    taskPayload = Factory.createPayload('task');

    var nestedQuestions;
    nestedQuestions = [
      Factory.createRecord('NestedQuestion', {
        ident: 'reviewer_report--decision_term'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'reviewer_report--competing_interests'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'reviewer_report--plos_biology_suitable'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'reviewer_report--plos_biology_suitable--comment'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'reviewer_report--statistical_analysis'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'reviewer_report--statistical_analysis--explanation'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'reviewer_report--standards'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'reviewer_report--standards--explanation'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'reviewer_report--additional_comments'
      }),
      Factory.createRecord('NestedQuestion', {
        ident: 'reviewer_report--identity'
      })
    ];

    addNestedQuestionsToTask(nestedQuestions, reviewerReportTask);
    var nestedQuestionsPayload = Factory.createPayload('nested_questions');
    nestedQuestionsPayload.addRecords(nestedQuestions);
    taskPayload.addRecords([reviewerReportTask, fakeUser]);
    reviewerReportTask = taskPayload.toJSON();

    var tasksPayload = Factory.createPayload('tasks');
    tasksPayload.addRecords([reviewerReportTask]);

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
        JSON.stringify(reviewerReportTask)]
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
      'Reviewer Report by Bob Jones'
    );
  });
});

test('Readonly mode: Not able to provide reviewer feedback', function(assert) {
  const url = '/papers/' + currentPaper.id + '/tasks/' + taskId;
  Factory.createPermission('ReviewerReportTask', taskId, ['view']);
  return visit(url).then(function() {
    assert.notOk(find('input[name*=reviewer_report--decision_term][type=radio][value=accept]').length, 'User cannot provide an accept for publication recommendation');
    assert.notOk(find('input[name*=reviewer_report--decision_term][type=radio][value=reject]').length, 'User cannot provide a reject recommendation');
    assert.notOk(find('input[name*=reviewer_report--decision_term][type=radio][value=major_revision]').length, 'User cannot provide a major revision recommendation');
    assert.notOk(find('input[name*=reviewer_report--decision_term][type=radio][value=minor_revision]').length, 'User cannot provide a minor revision recommendation');

    assert.notOk(find('textarea[name=reviewer_report--competing_interests]').length, 'User cannot provide their competing interests statement');

    assert.notOk(find('textarea[name=reviewer_report--competing_interests]').length, 'User cannot provide their competing interests statement');

    assert.notOk(find('input[name*=reviewer_report--plos_biology_suitable][type=radio][value=true]').length, 'User cannot provide yes response to biology suitability');
    assert.notOk(find('input[name*=reviewer_report--plos_biology_suitable][type=radio][value=false]').length, 'User cannot provide no response to biology suitability');
    assert.notOk(find('textarea[name=reviewer_report--plos_biology_suitable--comment]').length, 'User cannot provide their review of biology suitability');

    assert.notOk(find('input[name*=reviewer_report--statistical_analysis][type=radio][value=true]').length, 'User cannot provide respond yes to statistical analysis');
    assert.notOk(find('input[name*=reviewer_report--statistical_analysis][type=radio][value=false]').length, 'User cannot provide response no to statistical analysis');
    assert.notOk(find('textarea[name=reviewer_report--statistical_analysis--explanation]').length, 'User cannot provide their review of statistical analysis');

    assert.notOk(find('input[name*=reviewer_report--standards][type=radio][value=true]').length, 'User cannot provide respond yes to standards compliance');
    assert.notOk(find('input[name*=reviewer_report--standards][type=radio][value=false]').length, 'User cannot provide response no to standards compliance');
    assert.notOk(find('textarea[name=reviewer_report--standards--explanation]').length, 'User cannot provide their review of standards compliance');

    assert.notOk(find('textarea[name=reviewer_report--additional_comments]').length, 'User cannot provide additional comments');

    assert.notOk(find('textarea[name=reviewer_report--identity]').length, 'User cannot provide their identity');
  });
});


test('Edit mode: Providing reviewer feedback', function(assert) {
  const url = '/papers/' + currentPaper.id + '/tasks/' + taskId;
  Factory.createPermission('ReviewerReportTask', taskId, ['edit']);
  return visit(url).then(function() {
    assert.ok(find('input[name*=reviewer_report--decision_term][type=radio][value=accept]').length == 1, 'User can provide an accept for publication recommendation');
    assert.ok(find('input[name*=reviewer_report--decision_term][type=radio][value=reject]').length == 1, 'User can provide a reject recommendation');
    assert.ok(find('input[name*=reviewer_report--decision_term][type=radio][value=major_revision]').length == 1, 'User can provide a major revision recommendation');
    assert.ok(find('input[name*=reviewer_report--decision_term][type=radio][value=minor_revision]').length == 1, 'User can provide a minor revision recommendation');

    assert.ok(find('textarea[name=reviewer_report--competing_interests]').length == 1, 'User can provide their competing interests statement');

    assert.ok(find('textarea[name=reviewer_report--competing_interests]').length == 1, 'User can provide their competing interests statement');

    assert.ok(find('input[name*=reviewer_report--plos_biology_suitable][type=radio][value=true]').length == 1, 'User can respond yes to biology suitability');
    assert.ok(find('input[name*=reviewer_report--plos_biology_suitable][type=radio][value=false]').length == 1, 'User can respond no to biology suitability');
    assert.ok(find('textarea[name=reviewer_report--plos_biology_suitable--comment]').length == 1, 'User can provide their review of biology suitability');

    assert.ok(find('input[name*=reviewer_report--statistical_analysis][type=radio][value=true]').length == 1, 'User can provide respond yes to statistical analysis');
    assert.ok(find('input[name*=reviewer_report--statistical_analysis][type=radio][value=false]').length == 1, 'User can provide response no to statistical analysis');
    assert.ok(find('textarea[name=reviewer_report--statistical_analysis--explanation]').length == 1, 'User can provide their review of statistical analysis');

    assert.ok(find('input[name*=reviewer_report--standards][type=radio][value=true]').length == 1, 'User can provide respond yes to standards compliance');
    assert.ok(find('input[name*=reviewer_report--standards][type=radio][value=false]').length == 1, 'User can provide response no to standards compliance');
    assert.ok(find('textarea[name=reviewer_report--standards--explanation]').length == 1, 'User can provide their review of standards compliance');

    assert.ok(find('textarea[name=reviewer_report--additional_comments]').length == 1, 'User can provide additional comments');

    assert.ok(find('textarea[name=reviewer_report--identity]').length == 1, 'User can provide their identity');
  });
});
