import Ember from 'ember';
import { moduleFor, test } from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';

let sandbox;

moduleFor('route:application', 'Integration: pusher', {
  integration: true,
  afterEach() {
    sandbox.restore();
  },

  beforeEach() {
    sandbox = sinon.sandbox.create();

    manualSetup(this.container);
    this.route = this.subject();
    this.store = this.container.lookup('service:store');
    this.route.router = null; // this is needed for ember integration testing when calling internal methods
  }
});

test('action:created calls findRecord', function(assert) {
  assert.expect(1);
  const commentId = 12;

  sandbox.stub(this.store, 'findRecord');

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

  Ember.run(() => {
    // this is needed for ember integration testing
    // when calling internal methods
    this.route.send('created', {
      type: 'comment',
      id: commentId
    });

    assert.ok(this.store.findRecord.called, 'it fetches the changed object');
  });
});

test('action:destroy will delete the task from the store', function(assert) {
  assert.expect(2);
  const task1 = make('billing-task');
  const task2 = make('billing-task');
  const data = {
    type: 'task',
    id: task1.id
  };

  Ember.run(() => {
    this.route.send('destroyed', data);

    assert.ok(
      this.store.peekRecord('billing-task', task1.id) === null,
      'deletes the destroyed task'
    );

    assert.ok(
      this.store.peekRecord('billing-task', task2.id) !== null,
      'keeps other tasks'
    );
  });
});
