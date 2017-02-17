import { moduleFor, test } from 'ember-qunit';

moduleFor('service:feature-flag', 'Unit | Service | Feature flag', {
  needs: ['service:restless'],
  beforeEach() {
    const mockRestless = {
      get() {
        return {
          then(callback) {
            callback({
              activeFlag: true,
              inactiveFlag: false
            });
          }
        };
      }
    };

    this.service = new this.subject({
      restless: mockRestless
    });
  }
});

test('enabled returns a promise which resolves when a flag is enabled', function(assert) {
  const done = assert.async();
  this.service.enabled('activeFlag').then(() => {
    assert.ok(true, 'the then runs');
    done();
  }).catch(() => {
    assert.ok(false, 'the catch does not run');
    done();
  });
});

test('enabled returns a promise that rejects when a flag is disabled', function(assert) {
  const done = assert.async();
  this.service.enabled('inactiveFlag').then(() => {
    assert.ok(false, 'the then does not run');
    done();
  }).catch(() => {
    assert.ok(true, 'the catch runs');
    done();
  });
});

test('disabled returns a promise which resolves when a flag is disabled', function(assert) {
  const done = assert.async();
  this.service.disabled('inactiveFlag').then(() => {
    assert.ok(true, 'the then runs');
    done();
  }).catch(() => {
    assert.ok(false, 'the catch does not run');
    done();
  });
});


test('disabled returns a promise which rejects when a flag is enabled', function(assert) {
  const done = assert.async();
  this.service.disabled('activeFlag').then(() => {
    assert.ok(false, 'the then does not run');
    done();
  }).catch(() => {
    assert.ok(true, 'the catch runs');
    done();
  });
});


test('value returns a promise which yeilds a boolean', function(assert) {
  const done = assert.async();
  this.service.value('activeFlag').then((value) => {
    assert.ok(value, 'the flag is active');
    done();
  });

  const done2 = assert.async();
  this.service.value('inactiveFlag').then((value) => {
    assert.notOk(value, 'the flag is inactive');
    done2();
  });
});
