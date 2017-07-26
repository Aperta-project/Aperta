import Ember from 'ember';
import { moduleForModel, test } from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import startApp from '../helpers/start-app';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

var app;

moduleForModel('correspondence', 'Unit | Model | invitation', {
  needs: ['model:correspondence'],

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

test('manuscriptVersionStatus', function(assert) {
  // var shortTitle;
  // shortTitle = 'test short title';
  var paper = FactoryGuy.make('correspondence', {
  });
  assert.equal(paper.get('manuscriptStatus'), 'v0.0');  
  assert.equal(paper.get('manuscriptVersion'), 'rejected');
});
