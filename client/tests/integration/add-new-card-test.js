import Ember from 'ember';
import startApp from '../helpers/start-app';
import { paperWithParticipant } from '../helpers/setups';
import setupMockServer from '../helpers/mock-server';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

let app = null;
let server = null;

module('Integration: adding a new card', {
  afterEach() {
    server.restore();
    Ember.run(function() {
      return TestHelper.teardown();
    });
    return Ember.run(app, app.destroy);
  },

  beforeEach() {
    app = startApp();
    server = setupMockServer();
    TestHelper.handleFindAll('discussion-topic', 1);

    let adminJournalsResponse = {
      admin_journal: {
        id: 1,
        name: 'Test Journal of America',
        journal_task_type_ids: [1]
      },
      journal_task_types: [
        {
          id: 1,
          title: 'Ad Hoc',
          kind: 'Task',
          journal_id: 1
        }
      ]
    };

    let taskPayload = {
      task: {
        id: 2,
        title: 'Ad Hoc Task',
        type: 'Task',
        phase_id: 1,
        paper_id: 1,
        lite_paper_id: 1
      }
    };

    server.respondWith('GET', '\/api\/papers/1', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(paperWithParticipant().toJSON())
    ]);

    server.respondWith('POST', '\/api\/tasks', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(taskPayload)
    ]);

    server.respondWith('GET', '\/api\/admin/journals/1', [
      200, {
        'Content-Type': 'application/json'
      }, JSON.stringify(adminJournalsResponse)
    ]);
  }
});
