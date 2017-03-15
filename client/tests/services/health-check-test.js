import Ember from 'ember';
import { test, moduleFor } from 'ember-qunit';

let flash, server;
const health_uri = '/health';

moduleFor('service:health-check', 'Unit | Service | Health Check', {
  needs: [],

  afterEach() {
    $.mockjax.clear()
  }
});

test('response to an Error 500', function(assert) {
  assert.expect(2);

  let spy = function() {
    assert.ok(true, 'it calls displayErrorAndStopPolling');
  };
  let healthService = this.subject({displayErrorAndStopPolling: spy});

  $.mockjax({
    url: health_uri,
    status: 500,
    responseText: 'unhealthy'
  });

  return healthService.checkHealthEndpoint().then(null, () => {
    assert.ok(true, 'the promise rejects');
  });

});

test('response to a Success 200', function(assert) {
  assert.expect(1);

  let spy = function() {
    assert.ok(false, 'it should not call displayErrorAndStopPolling');
  };
  let healthService = this.subject({displayErrorAndStopPolling: spy});

  $.mockjax({
    url: health_uri,
    status: 200,
    responseText: 'healthy'
  });

  return healthService.checkHealthEndpoint().then(() => {
    assert.ok(true, 'the promise resolves');
  }, null);

});
