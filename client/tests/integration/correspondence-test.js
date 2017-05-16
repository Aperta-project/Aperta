import Ember from 'ember';
import {
  test
} from 'ember-qunit';
import startApp from '../helpers/start-app';
import setupMockServer from '../helpers/mock-server';
import Factory from '../helpers/factory';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';

import FactoryGuy from 'ember-data-factory-guy';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import formatDate from 'tahi/lib/format-date';

var app, paper, correspondence, server;

app = null;
server = null;
paper = null;
correspondence = null;

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

    correspondence = FactoryGuy.make('correspondence');
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

test('User can view a correspondence record', function(assert) {
  visit('/papers/' + paper.get('shortDoi') + '/correspondence/viewcorrespondence/1');
  return andThen(function() {
    assert.ok(find('.correspondence-overlay'), 'Correspondence Overlay');
    assert.equal(find('.correspondence-date').text().trim(), formatDate(correspondence.get('date'), {}));
    assert.equal(find('.correspondence-sender').text().trim(), correspondence.get('sender'));
    assert.equal(find('.correspondence-recipient').text().trim(), correspondence.get('recipient'));
    assert.equal(find('.correspondence-subject').text().trim(), correspondence.get('subject'));
  });
});

test('User can click on a correspondence to view it\'s recodes', function(assert) {
  visit('/papers/' + paper.get('shortDoi') + '/correspondence');
  click('.correspondence1 a');
  return andThen(function() {
    assert.equal(currentURL(), '/papers/' + paper.get('shortDoi') + '/correspondence/viewcorrespondence/1');
  });
});
