import Ember from 'ember';
import { module, test } from 'qunit';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import Factory from '../helpers/factory';
import startApp from '../helpers/start-app';
import setupMockServer from '../helpers/mock-server';
import {
  paperWithTask, addUserAsParticipant, addNestedQuestionToTask
} from '../helpers/setups';

let app      = null;
let server   = null;
let fakeUser = null;
const taskId = 90210;

module('Integration: Reporting Guidelines Card', {
  afterEach() {
    server.restore();
    Ember.run(function() { TestHelper.teardown(); });
    Ember.run(app, 'destroy');
  },

  beforeEach() {
    app      = startApp();
    server   = setupMockServer();
    fakeUser = window.currentUserData.user;

    const records = paperWithTask('ReportingGuidelinesTask', {
      id: taskId,
      oldRole: 'author'
    });

    Factory.createPermission('ReportingGuidelinesTask', taskId, ['edit']);
    TestHelper.handleFindAll('discussion-topic', 1);

    const task = records[1];

    // -- Paper Setup

    const paperPayload = Factory.createPayload('paper');
    paperId = paperPayload.id;
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

    const nestedQuestions = [];
    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 1, ident: 'reporting_guidelines--clinical_trial', text: 'Whatever' }));
    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 2, ident: 'reporting_guidelines--systematic_reviews', text: 'Systematic Reviews' }));
    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 22, parent_id: 2, ident: 'reporting_guidelines--systematic_reviews--checklist', text: 'Provide a completed PRISMA checklist as supporting information.' }));
    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 3, ident: 'reporting_guidelines--meta_analyses', text: 'Whatever' }));
    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 33, parent_id: 3, ident: 'reporting_guidelines--meta_analyses--checklist', text: 'Whatever' }));
    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 4, ident: 'reporting_guidelines--diagnostic_studies', text: 'Whatever' }));
    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 5, ident: 'reporting_guidelines--epidemiological_studies', text: 'Whatever' }));
    nestedQuestions.push(Factory.createRecord('NestedQuestion', { id: 6, ident: 'reporting_guidelines--microarray_studies', text: 'Whatever' }));
    _.each(nestedQuestions, function(nestedQuestion) {
      addNestedQuestionToTask(nestedQuestion, task);
    });

    server.respondWith('GET', '/api/tasks/' + taskId + '/nested_questions', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify({ nested_questions: nestedQuestions })
    ]);

    server.respondWith('GET', '/api/tasks/' + taskId + '/nested_question_answers', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify({nested_question_answers: []})
    ]);

    server.respondWith('GET', '/api/journals', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify({journals:[]})
    ]);

    server.respondWith('POST', '/api/nested_questions/' + nestedQuestions[1].id + '/answers', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify({})
    ]);
  }
});

test('Supporting Guideline is a meta data card, contains the right questions and sub-questions', function(assert) {
  const findQuestionLi = function(questionText) {
    return find('.question .item').filter(function(i, el) {
      return Ember.$(el).find('label').text().trim() === questionText;
    });
  };

  visit('/papers/' + paperId + '/tasks/' + taskId).then(function() {
    assert.equal(find('.question .item').length, 6);
    assert.equal(find('.overlay-body-title').text().trim(), 'Reporting Guidelines');
    const questionLi = findQuestionLi('Systematic Reviews');
    // assert.ok(!questionLi.find('.additional-data input[type=file]').length);
  });

  click('input[name="reporting_guidelines--systematic_reviews"]').then(function() {
    const questionLi = findQuestionLi('Systematic Reviews');
    assert.equal(0, questionLi.find('.additional-data.hidden').length);
    // assert.ok(questionLi.find('.additional-data input[type=file]').length);
    const additionalDataText = questionLi.find('.additional-data').text();
    // assert.ok(additionalDataText.indexOf('Select & upload') > -1);
    // return assert.ok(additionalDataText.indexOf('Provide a completed PRISMA checklist as supporting information.') > -1);
  });
});
