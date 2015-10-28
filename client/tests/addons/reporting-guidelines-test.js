import Ember from "ember";
import { module, test } from "qunit";
import startApp from "../helpers/start-app";
import { paperWithTask, addUserAsParticipant, addNestedQuestionToTask } from "../helpers/setups";
import setupMockServer from "../helpers/mock-server";
import Factory from "../helpers/factory";
import TestHelper from "ember-data-factory-guy/factory-guy-test-helper";
var app, currentPaper, fakeUser, server;

app = null;
server = null;
fakeUser = null;
currentPaper = null;

module('Integration: Reporting Guidelines Card', {
  afterEach: function() {
    server.restore();
    Ember.run(function() {
      return TestHelper.teardown();
    });
    return Ember.run(app, app.destroy);
  },

  beforeEach: function() {
    var paperPayload, paperResponse, records, task, taskId, taskPayload, taskResponse;
    app = startApp();
    server = setupMockServer();
    fakeUser = window.currentUserData.user;
    TestHelper.handleFindAll("discussion-topic", 1);
    taskId = 94139;

    records = paperWithTask("ReportingGuidelinesTask", {
      id: taskId,
      role: "author"
    });

    currentPaper = records[0];
    task = records[1];

    paperPayload = Factory.createPayload('paper');
    paperPayload.addRecords(records.concat([fakeUser]));
    paperResponse = paperPayload.toJSON();
    paperResponse.participations = [addUserAsParticipant(task, fakeUser)];


    taskPayload = Factory.createPayload('task');
    taskPayload.addRecords([task, fakeUser]);
    taskResponse = taskPayload.toJSON();

    var nestedQuestions = [];

    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 1, ident: 'clinical_trial', text: "Doesn't Matter" }));
    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 2, ident: 'systematic_reviews', text: "Systematic Reviews" }));
    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 22, parent_id: 2, ident: 'checklist', text: "Provide a completed PRISMA checklist as supporting information." }));
    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 3, ident: 'meta_analyses', text: "Doesn't Matter" }));
    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 33, parent_id: 3, ident: 'checklist', text: "Doesn't Matter" }));
    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 4, ident: 'diagnostic_studies', text: "Doesn't Matter" }));
    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 5, ident: 'epidemiological_studies', text: "Doesn't Matter" }));
    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 6, ident: 'microarray_studies', text: "Doesn't Matter" }));
    _.each(nestedQuestions, function(nestedQuestion) {
      addNestedQuestionToTask(nestedQuestion, task);
    });
    var nestedQuestionsPayload = {nested_questions: nestedQuestions};

    server.respondWith('GET', "/api/papers/" + currentPaper.id, [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify(paperResponse)
    ]);

    server.respondWith('GET', "/api/tasks/" + taskId, [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify(taskResponse)
    ]);

    server.respondWith('GET', "/api/tasks/" + taskId + "/nested_questions", [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify(nestedQuestionsPayload)
    ]);

    server.respondWith('GET', "/api/tasks/" + taskId + "/nested_question_answers", [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify({nested_question_answers: []})
    ]);

    return server.respondWith('POST', "/api/nested_questions/" + nestedQuestions[1].id + "/answers", [
      200, {
        "Content-Type": "application/json"
      }, JSON.stringify({})
    ]);
  }
});

test('Supporting Guideline is a meta data card, contains the right questions and sub-questions', function(assert) {
  var findQuestionLi;
  findQuestionLi = function(questionText) {
    return find('.question .item').filter(function(i, el) {
      return Ember.$(el).find('label').text().trim() === questionText;
    });
  };
  visit("/papers/" + currentPaper.id).then(function() {
    return assert.ok(find('#paper-metadata-tasks .card-content:contains("Reporting Guidelines")'));
  });
  click('.card-content:contains("Reporting Guidelines")').then(function() {
    var questionLi;
    assert.equal(find('.question .item').length, 6);
    assert.equal(find(".overlay-main-work h1").text().trim(), "Reporting Guidelines");
    questionLi = findQuestionLi('Systematic Reviews');
    return assert.ok(!questionLi.find('.additional-data input[type=file]').length);
  });
  return click('input[name="systematic_reviews"]').then(function() {
    var additionalDataText, questionLi;
    questionLi = findQuestionLi('Systematic Reviews');
    assert.equal(0, questionLi.find('.additional-data.hidden').length);
    assert.ok(questionLi.find('.additional-data input[type=file]').length);
    additionalDataText = questionLi.find('.additional-data').text();
    assert.ok(additionalDataText.indexOf('Select & upload') > -1);
    return assert.ok(additionalDataText.indexOf('Provide a completed PRISMA checklist as supporting information.') > -1);
  });
});
