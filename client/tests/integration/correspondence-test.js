/*import Ember from 'ember';
import {
  test
} from 'ember-qunit';
import startApp from '../helpers/start-app';
import setupMockServer from '../helpers/mock-server';
import Factory from '../helpers/factory';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';

import FactoryGuy from 'ember-data-factory-guy';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

var app, paper, server;

app = null;
server = null;
paper = null;

moduleForAcceptance('Integration: Correspondence', {
  afterEach: function() {
    server.restore();
    Ember.run(function() {
      return TestHelper.teardown();
    });
    Ember.run(app, app.destroy);
    $.mockjax.clear();
  },
  beforeEach: function() {
    app = startApp();
    TestHelper.setup();
    server = setupMockServer();

    let correspondence = FactoryGuy.make('correspondence');
    paper = FactoryGuy.make('paper', {
      correspondence: [correspondence]
    });

    TestHelper.mockPaperQuery(paper);
    TestHelper.mockFindAll('journal', 0);

    Factory.createPermission('Paper', paper.id, ['submit', 'manage_workflow']);
    $.mockjax({
      url: `/api/papers/${paper.get('shortDoi')}`,
      type: 'put',
      status: 204
    });

    $.mockjax({
      type: 'GET',
      url: '/api/feature_flags.json',
      status: 200,
      responseText: {
        CORRESPONDENCE: true
      }
    });
  }
});

test('User can click on a correspondence', function(assert) {
  visit('/papers/' + paper.get('shortDoi') + '/correspondence');
  return andThen(function() {
    click('#link1');
    assert.elementFound('.correspondence-overlay');
    assert.ok(find('.overlay-header-title').text, 'Correspondence Record');
  });
});*/
