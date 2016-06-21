import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from '../helpers/start-app';
import { paperWithTask, addUserAsParticipant, addNestedQuestionToTask } from '../helpers/setups';
import setupMockServer from '../helpers/mock-server';
import Factory from '../helpers/factory';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

var app, currentPaper, fakeUser, financialDisclosureTask,
    financialDisclosureTaskId, paperPayload, server;

app = null;
server = null;
fakeUser = null;
currentPaper = null;
financialDisclosureTaskId = 94139;
financialDisclosureTask = null;
paperPayload = null;

module('Integration: FinancialDisclosure', {
  teardown: function() {
    server.restore();
    return Ember.run(app, app.destroy);
  },

  setup: function() {
    var collaborators, journal, mirrorCreateResponse, paperResponse,
        phase, records, taskPayload;
    app = startApp();
    server = setupMockServer();
    fakeUser = window.currentUserData.user;
    TestHelper.handleFindAll('discussion-topic', 1);

    records = paperWithTask('FinancialDisclosureTask', {
      id: financialDisclosureTaskId,
      oldRole: 'author'
    });

    Factory.createPermission(
      'FinancialDisclosureTask',
      financialDisclosureTaskId,
      ['edit']);

    currentPaper = records[0];
    financialDisclosureTask = records[1];
    journal = records[2];
    phase = records[3];

    paperPayload = Factory.createPayload('paper');
    paperPayload.addRecords(records.concat([fakeUser]));
    paperResponse = paperPayload.toJSON();
    paperResponse.participations =
      [addUserAsParticipant(financialDisclosureTask, fakeUser)];

    taskPayload = Factory.createPayload('task');

    var nestedQuestion;
    nestedQuestion = Factory.createRecord(
      'NestedQuestion',
      { ident: 'financial_disclosures--author_received_funding' });
    addNestedQuestionToTask(nestedQuestion, financialDisclosureTask);
    var nestedQuestionsPayload = Factory.createPayload('nested_questions');
    nestedQuestionsPayload.addRecords([nestedQuestion]);

    taskPayload.addRecords([financialDisclosureTask, fakeUser]);

    financialDisclosureTask = taskPayload.toJSON();
    collaborators = [
      {
        id: '35',
        full_name: 'Aaron Baker',
        info: 'testroles2, collaborator'
      }
    ];

    var tasksPayload = Factory.createPayload('tasks');
    tasksPayload.addRecords([financialDisclosureTask]);

    server.respondWith('GET', "/api/papers/" + currentPaper.id, [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify(paperResponse)
    ]);

    server.respondWith('GET', "/api/papers/" + currentPaper.id + "/tasks", [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify(tasksPayload.toJSON())
    ]);

    server.respondWith('GET', "/api/tasks/" + financialDisclosureTaskId + "/nested_questions", [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify(nestedQuestionsPayload.toJSON())
    ]);

    server.respondWith('GET', "/api/tasks/" + financialDisclosureTaskId + "/nested_question_answers", [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify({nested_question_answers: []})
    ]);

    server.respondWith('GET', "/api/tasks/" + financialDisclosureTaskId, [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify(financialDisclosureTask)
    ]);

    server.respondWith('PUT', /\/api\/tasks\/\d+/, [204, {'Content-Type': 'application/json' }, ""]);

    server.respondWith('GET', /\/api\/filtered_users\/users\/\d+/, [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify([])
    ]);

    server.respondWith('GET', '/api/nested_questions?type=Funder', [200, { 'Content-Type': 'application/json' }, JSON.stringify(
      { nested_questions: [
        {id: 120, text: 'A question to be checked', value_type: 'boolean', ident: 'funder--had_influence' },
      ] }
    ) ]);

    server.respondWith('POST', `/api/nested_questions/${nestedQuestion.id}/answers`, [
      204, {
        "Content-Type": "application/json"
      }, JSON.stringify([])
    ]);

    server.respondWith('DELETE', /\/api\/funders\/\d+/, [
      204, {
        "Content-Type": "application/html"
      }, ""
    ]);

    server.respondWith('GET', '/api/journals', [200, { 'Content-Type': 'application/json' }, JSON.stringify({journals:[]})]);

    mirrorCreateResponse = function(key, newId) {
      return function(xhr) {
        var createdItem, response;
        createdItem = JSON.parse(xhr.requestBody);
        createdItem[key].id = newId;
        response = JSON.stringify(createdItem);
        return xhr.respond(201, {
          "Content-Type": "application/json"
        }, response);
      };
    };
    return server.respondWith('POST', '/api/funders', mirrorCreateResponse('funder', 1));
  }
});

test('Viewing the card and adding new funder', function(assert) {
  visit("/papers/" + currentPaper.id + "/tasks/" + financialDisclosureTaskId).then(function() {
    assert.equal(find('.overlay-body-title').text().trim(), 'Financial Disclosure');
    assert.elementFound(
      "label:contains('Yes')",
      'User can find the \'yes\' option\''
    );
    click("label:contains('Yes')");
    return andThen(function() {
      assert.elementFound(
        "button:contains('Add Another Funder')",
        'User can add another funder'
      );
      assert.elementFound(
        "span.remove-funder",
        'User can add remove the funder'
      );
      Ember.$('.funder-name').val("Hello");
      Ember.$('.grant-number').val("1234567890");
      click(".task-completed");
    });
  });
});

test("Removing an existing funder when there's only 1", function(assert) {
  visit("/papers/" + currentPaper.id + "/tasks/" + financialDisclosureTaskId);
  click("label:contains('Yes')");
  click("span.remove-funder");
  return andThen(function() {
    assert.ok(!find('input#received-funding-no:checked').length, "Returned to netual");
    return assert.ok(!find('input#received-funding-yes:checked').length, "Returned to netual");
  });
});
