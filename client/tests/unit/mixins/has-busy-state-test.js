import Ember from 'ember';
import HasBusyStateMixin from '../../../mixins/has-busy-state';
import { module, test } from 'qunit';

module('Unit | Mixin | has busy state');

test('busyWhile sets and unsets busy property', function(assert) {
  let HasBusyStateObject = Ember.Object.extend(HasBusyStateMixin);
  let subject = HasBusyStateObject.create();

  assert.notOk(subject.get('busy'));

  const start = assert.async();

  const busyPromise = new Ember.RSVP.Promise(function (resolve, reject) {
    let tries = 0;
    let f = function () {
      tries += 1;
      const busy = subject.get('busy');
      if (busy !== true) {
        if (tries > 3) {
          assert.notOk(busy, 'Waited too long to set busy.');
          reject();
        } else {
          setTimeout(f, 10);
        }
      } else {
        assert.ok(busy);
        resolve();
      }
    };
    // We have no guarantee that the busy state will be set before this code
    // runs, so we need to poll until we see that it is set.
    setTimeout(f, 10);
  });

  subject.busyWhile(busyPromise).finally(() => {
    assert.notOk(subject.get('busy'));
    start();
  });
});
