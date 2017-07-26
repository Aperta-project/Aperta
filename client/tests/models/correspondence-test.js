import Ember from 'ember';
import { moduleForModel, test } from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import startApp from '../helpers/start-app';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

var app;

<<<<<<< 6e0b058dbaa27571f6d99399be473e984789d018
moduleForModel('correspondence', 'Unit | Model | Correspondence', {
  needs: ['model:correspondence', 'model:paper'],
=======
moduleForModel('correspondence', 'Unit | Model | invitation', {
  needs: ['model:correspondence'],
>>>>>>> APERTA-9677 #wip re-factored components tests

  afterEach: function() {
    Ember.run(function() {
      return TestHelper.teardown();
    });
    return Ember.run(app, 'destroy');
  },
  beforeEach: function() {
    app = startApp();
    return TestHelper.setup(app);
  }
});

<<<<<<< 6e0b058dbaa27571f6d99399be473e984789d018
test('manuscriptVersionStatus with  valid values', function(assert) {
  var correspondence = FactoryGuy.make('correspondence', {
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
  var correspondence = FactoryGuy.make('correspondence', {
  });
  
  var scenarios = [
    {
      data: {
        manuscriptVersion: 'v2.0',
        manuscriptStatus: 'submitted',
      },
    },
  ];
  scenarios.forEach(function(scenario) {
    Ember.run(function() {
      correspondence.setProperties(scenario.data);
    }),
    assert.equal(correspondence.get('manuscriptVersionStatus'), 'v2.0 submitted');
  });
}); 
=======
test('manuscriptVersionStatus', function(assert) {
  // var shortTitle;
  // shortTitle = 'test short title';
  var paper = FactoryGuy.make('correspondence', {
  });
  assert.equal(paper.get('manuscriptStatus'), 'v0.0');  
  assert.equal(paper.get('manuscriptVersion'), 'rejected');
});
>>>>>>> APERTA-9677 #wip re-factored components tests
