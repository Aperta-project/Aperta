import Ember from 'ember';
import { test } from 'ember-qunit';
import startApp from '../helpers/start-app';
import FactoryGuy from 'ember-data-factory-guy';

let app, sandbox, route, store;

module('Integration: Pusher', {
  afterEach() {
    store = null;
    route = null;
    Ember.run(app, app.destroy);
    sandbox.restore();
  },

  beforeEach() {
    app = startApp();
    sandbox = sinon.sandbox.create();
    store = getStore();
    route = getContainer().lookup('route:application');
    route.router = null; // this is needed for ember integration testing when calling internal methods
  }
});

test('action:created calls findRecord', function(assert) {
  assert.expect(1);
  const commentId = 12;

  sandbox.stub(store, 'findRecord');

  $.mockjax({
    url: '/api/comments/12',
    status: 200,
    contentType: 'application/json',
    responseText: {
      comment: {
        id: commentId,
        body: 'testing 123'
      }
    }
  });

  Ember.run(()=> {
      const route = getContainer().lookup('route:application');
      // this is needed for ember integration testing
      // when calling internal methods
      route.send('created', {
        type: 'comment',
        id: commentId
      });

      assert.ok(store.findRecord.called, 'it fetches the changed object');
    });
});

test('action:destroy will delete the task from the store', function(assert) {
  expect(2);
  const task1 = FactoryGuy.make('billing-task');
  const task2 = FactoryGuy.make('billing-task');
  const data = {
    type: 'task',
    id: task1.id
  };

  Ember.run(function() {
    route.send('destroyed', data);

    assert.ok(
      store.peekRecord('billing-task', task1.id) === null,
      'deletes the destroyed task'
    );

    assert.ok(
      store.peekRecord('billing-task', task2.id) !== null,
      'keeps other tasks'
    );
  });
});
