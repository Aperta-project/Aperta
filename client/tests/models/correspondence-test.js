import Ember from 'ember';
import { moduleFor, test } from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';

moduleFor('model:correspondence', 'Unit | Model | Correspondence', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
  }
});

test('manuscriptVersionStatus with  valid values', function(assert) {
  var correspondence = make('correspondence', {
  });
  var scenarios = [
    {
      data: {
        manuscriptVersion: null,
        manuscriptStatus: null,
      },
    },
  ];
  scenarios.forEach(function(scenario) {
    Ember.run(function() {
      correspondence.setProperties(scenario.data);
    }),
    assert.equal(correspondence.get('manuscriptVersionStatus'), 'Unavailable');
  });
});

test('manuscriptVersionStatus for external correspondence and old papers', function(assert) {
  var correspondence = make('correspondence', {
  });

  var scenarios = [
    {
      data: {
        manuscriptVersion: 'v2.0',
        manuscriptStatus: 'submitted'
      }
    }
  ];
  scenarios.forEach(function(scenario) {
    Ember.run(function() {
      correspondence.setProperties(scenario.data);
    }),
    assert.equal(correspondence.get('manuscriptVersionStatus'), 'v2.0 submitted');
  });
});
