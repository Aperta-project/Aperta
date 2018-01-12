import { test, moduleFor } from 'ember-qunit';

moduleFor('service:bugsnag', 'Unit | Service | Bugsnag', {
  needs: [],

  beforeEach() {
    this.service = this.subject();
  }
});

function withBugsnag(test) {
  const notifyExceptionSpy = sinon.spy();
  const bugsnag = window.Bugsnag;
  window.Bugsnag = {
    notifyException: notifyExceptionSpy
  };
  test.call(this, notifyExceptionSpy);
  window.Bugsnag = bugsnag;
}

function withoutBugsnag(test) {
  const bugsnag = window.Bugsnag;
  delete window.Bugsnag;
  test.call();
  window.Bugsnag = bugsnag;
}

test('notifyException() should work without Bugsnag', function(assert) {
  withoutBugsnag(() => {
    this.service.notifyException(new Error(), 'Tis but a flash wound');
    assert.ok('things dont blow up');
  });
});

test('notifyException() should work with Bugsnag', function(assert) {
  withBugsnag((notifyExceptionSpy) => {
    this.service.notifyException(new Error(), 'We are the knights who assert Ni!');
    assert.spyCalled(notifyExceptionSpy);
  });
});
