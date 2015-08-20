import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'tahi/tests/helpers/start-app';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

let App = null;
let title = 'Crystalized Magnificence in the Modern World';

module('Integration: Create new paper', {
  afterEach() {
    Ember.run(function() {
      TestHelper.teardown();
      Ember.run(App, 'destroy');
    });
  },

  beforeEach() {
    App = startApp();
    TestHelper.setup(App);

    // We don't care about having data on the page when testing the new paper form

    TestHelper.handleFindAll('journal', 1);
    TestHelper.handleFindAll('paper', 0);
    TestHelper.handleFindAll('invitation', 0);
    TestHelper.handleFindAll('comment-look', 0);
    TestHelper.handleFindAll('discussion-topic', 0);
    $.mockjax({url: /\/api\/papers\/\d+\/manuscript_manager/, status: 204});
    $.mockjax({url: '/api/admin/journals/authorization', status: 204});
    $.mockjax({url: '/api/user_flows/authorization', status: 204});
  }
});

test('author successfully creates a submission', function(assert) {
  TestHelper.handleCreate('paper');

  visit('/');
  click('.button-primary:contains(Create New Submission)');
  fillIn('#paper-short-title', title);
  pickFromSelectBox('.paper-new-journal-select', 'PLOS Yeti 1');
  pickFromSelectBox('.paper-new-paper-type-select', 'Research');
  click('.paper-new-create-document-button');

  andThen(function() {
    assert.ok(find('#paper-title').length, 'on Paper Edit screen');
  });
});

test('author unsuccessfully creates a submission', function(assert) {
  TestHelper.handleCreate('paper').andFail({
    status: 422, response: {'errors':{'paper_type':['can\'t be blank']}}
  });

  visit('/');
  click('.button-primary:contains(Create New Submission)');
  fillIn('#paper-short-title', title);
  pickFromSelectBox('.paper-new-journal-select', 'PLOS Yeti 1');
  click('.paper-new-create-document-button');

  andThen(function() {
    assert.ok(find('.flash-message--error').length, 'error on screen');
  });
});

test('feedback is displayed after submission', function(assert) {
  let paperNewController = App.__container__.lookup('controller:overlays/paper-new');

  visit('/');
  click('.button-primary:contains(Create New Submission)').then(function() {
    Ember.run(this, function() {
      paperNewController.set('model', {});
      paperNewController.set('model.isSaving', true);
    });
  });

  andThen(function() {
    assert.ok(find('.progress-spinner').length, 'spinner visible');
  });
});
