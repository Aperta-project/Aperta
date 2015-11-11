import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'tahi/tests/helpers/start-app';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

let App = null;

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

test('error is displayed after failed submission', function(assert) {
  const paperNewController = App.__container__.lookup('controller:overlays/paper-new');

  TestHelper.handleCreate('paper').andFail({
    status: 422, response: {'errors':{'paper_type':['can\'t be blank']}}
  });

  visit('/');
  click('.button-primary:contains(Create New Submission)').then(function() {
    // Calling an action here to skip file uploading process
    paperNewController.send('createPaperWithUpload');
    // createPaperWithUpload returns a promise
    // the wait helper will... wait
    wait();
  });

  andThen(function() {
    assert.ok(find('.flash-message--error:contains(blank)').length, 'error on screen');
  });
});

test('author successfully creates a submission', function(assert) {
  TestHelper.handleCreate('paper');
  const paperNewController = App.__container__.lookup('controller:overlays/paper-new');

  // Mocking out what the FileUploadMixin provides.
  // This test skips selecting a file and calls the action manually/
  paperNewController.uploadFinished = function() {};
  paperNewController.uploadFunction = function() {
    paperNewController.send('uploadFinished', {}, 'file.docx');
  };

  visit('/');
  click('.button-primary:contains(Create New Submission)');
  fillIn('#new-paper-title', 'Testing 123');
  pickFromSelectBox('.paper-new-journal-select', 'PLOS Yeti 1');
  pickFromSelectBox('.paper-new-paper-type-select', 'Research').then(function() {
    // Skipping selecting a file and calling action manually
    paperNewController.send('createPaperWithUpload');
    wait();
  });

  andThen(function() {
    assert.ok(find('#paper-title').length, 'on Paper Edit screen');
  });
});

test('feedback is displayed', function(assert) {
  const paperNewController = App.__container__.lookup('controller:overlays/paper-new');

  visit('/');
  click('.button-primary:contains(Create New Submission)').then(function() {
    Ember.run(this, function() {
      paperNewController.set('isSaving', true);
    });
  });

  andThen(function() {
    const spinner = find('.progress-spinner');
    const uploadButton = find('.paper-new-upload-button');

    assert.ok(spinner.length, 'spinner visible');
    assert.ok(uploadButton.hasClass('button--disabled'), 'button is disabled');
  });
});
