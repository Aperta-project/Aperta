import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import Factory from 'tahi/tests/helpers/factory';
import wait from 'ember-test-helpers/wait';
import { createCard } from 'tahi/tests/factories/card';

moduleForComponent(
  'authors-task',
  'Integration | Components | Tasks | Authors', {
    integration: true,
    beforeEach() {
      manualSetup(this.container);
      this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
      Factory.createPermission('authorsTask', 1, ['edit', 'view']);
      createCard('Author');
      createCard('GroupAuthor');
      createCard('TahiStandardTasks::AuthorsTask');

      // For any answers that will be sent to the server
      $.mockjax({url: /api\/answers/, status: 204});
      $.mockjax({url: /api\/journals/, status: 200, responseText: {
        journals: []
      }
      });
      $.mockjax({url: '/api/countries', status: 200, responseText: {
        countries: []
      }});
    },
    afterEach() {
      $.mockjax.clear();
    }
  });

let createTask = function() {
  let task = make('authors-task', {
    id: 1,
    paper: { authors: [] }
  });
  return task;
};

let createTaskWithInvalidAuthor = function() {
  let task = make('authors-task', {
    id: 1,
    paper: { authors: [make('author')] }
  });
  return task;
};


let template = hbs`{{authors-task task=testTask}}`;

test('it renders the paper\'s authors', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);

  return wait().then(() => {
    assert.elementsFound('.authors-task', 1);
  });
});

test('it reports validation errors on the task when attempting to complete', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);
  this.$('.authors-task button.task-completed').click();

  return wait().then(() => {
    // Error at the task level
    assert.textPresent('.authors-task', 'Please fix all errors');
  });
});

test('it does not allow the user to complete when there are validation errors', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);
  this.$('.authors-task button.task-completed').click();

  return wait().then(() => {
    assert.equal(testTask.get('completed'), false, 'task remained incomplete');
  });
});

test('it requires validation on the user confirming authors agree to being named', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);

  $.mockjax({url: '/api/answers/1', type: 'POST', status: 201, responseText: '{}'});

  // Make sure the other answers are checked
  this.$('.authors-task input[name="authors--authors_confirm_icmje_criteria"]').click();
  this.$('.authors-task input[name="authors--authors_agree_to_submission"]').click();

  // try to complete
  this.$('.authors-task button.task-completed').click();

  return wait().then(() => {
    assert.textPresent(
      '.authors-task .authors-task-acknowledgements .error-message:not(.error-message--hidden)',
      'Please acknowledge the statements below'
    );
  });
});

test('it requires validation on the user confirming ICMJE criteria', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);

  // Make sure the other answers are checked
  this.$('.authors-task input[name="authors--persons_agreed_to_be_named"]').click();
  this.$('.authors-task input[name="authors--authors_agree_to_submission"]').click();

  // try to complete
  this.$('.authors-task button.task-completed').click();

  return wait().then(() => {
    assert.textPresent(
      '.authors-task .authors-task-acknowledgements .error-message:not(.error-message--hidden)',
      'Please acknowledge the statements below'
    );
  });
});

test('it requires validation on the user confirming author submission', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);
  this.render(template);

  // Make sure the other answers are checked
  this.$('.authors-task input[name="authors--persons_agreed_to_be_named"]').click();
  this.$('.authors-task input[name="authors--authors_confirm_icmje_criteria"]').click();

  // try to complete
  this.$('.authors-task button.task-completed').click();

  return wait().then(() => {
    assert.textPresent(
      '.authors-task .authors-task-acknowledgements .error-message:not(.error-message--hidden)',
      'Please acknowledge the statements below'
    );
  });
});

test('it requires its authors to be valid', function(assert){
  let testTask = createTaskWithInvalidAuthor();
  this.set('testTask', testTask);
  this.render(template);
  window.RailsEnv.orcidConnectEnabled = true;

  // Make sure required questions on the task are answered
  this.$('.authors-task input[name="authors--persons_agreed_to_be_named"]').click();
  this.$('.authors-task input[name="authors--authors_confirm_icmje_criteria"]').click();
  this.$('.authors-task input[name="authors--authors_agree_to_submission"]').click();

  // try to complete
  this.$('.authors-task button.task-completed').click();

  return wait().then(() => {
    // These individual validations should eventually get moved over
    // to the author-form-test
    assert.textPresent('.authors-task', 'Please fix all errors');
    assert.elementFound(
      '.orcid-connect.error',
      'orcid connect error'
    );
    //   TODO: assert that orcid validation doesn't happen when the feature is disabled
    //   window.RailsEnv.orcidConnectEnabled = false;
    assert.elementFound(
      '[data-test-id="author-initial"].error',
      'presence error on initial'
    );
    assert.elementFound(
      '[data-test-id="author-affiliation"].error',
      'presence error on affiliation'
    );
    assert.elementFound(
      '[data-test-id="author-government"] .error-message:visible',
      'presence error on government'
    );
  });
});

test('it does not show orcid errors when the feature flag is off', function(assert){
  let testTask = createTaskWithInvalidAuthor();
  this.set('testTask', testTask);
  this.render(template);
  window.RailsEnv.orcidConnectEnabled = false;

  // Make sure required questions on the task are answered
  this.$('.authors-task input[name="authors--persons_agreed_to_be_named"]').click();
  this.$('.authors-task input[name="authors--authors_confirm_icmje_criteria"]').click();
  this.$('.authors-task input[name="authors--authors_agree_to_submission"]').click();

  // try to complete
  this.$('.authors-task button.task-completed').click();

  return wait().then(() => {
    // These individual validations should eventually get moved over
    // to the author-form-test
    assert.textPresent('.authors-task', 'Please fix all errors');
    assert.elementNotFound(
      '.orcid-connect.error',
      'orcid connect error'
    );
  });
});

test('it lets you complete the task when there are no validation errors', function(assert) {
  let testTask = createTask();
  this.set('testTask', testTask);

  $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});
  this.render(template);

  // Answer required questions
  this.$('.authors-task input[name="authors--persons_agreed_to_be_named"]').click();
  this.$('.authors-task input[name="authors--authors_confirm_icmje_criteria"]').click();
  this.$('.authors-task input[name="authors--authors_agree_to_submission"]').click();

  // try to complete
  this.$('.authors-task button.task-completed').click();

  return wait().then(() => {
    assert.equal(testTask.get('completed'), true, 'task was completed');
    assert.mockjaxRequestMade('/api/tasks/1', 'PUT');
  });
});

test('it lets you uncomplete the task when it and its authors have validation errors', function(assert) {
  let testTask = createTaskWithInvalidAuthor();
  this.set('testTask', testTask);

  Ember.run(() => {
    testTask.set('completed', true);
  });

  $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});

  this.render(template);

  assert.equal(testTask.get('completed'), true, 'task was initially completed');
  this.$('.authors-task button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.equal(testTask.get('completed'), false, 'task was marked as incomplete');
    assert.mockjaxRequestMade('/api/tasks/1', 'PUT');
    $.mockjax.clear();
    $.mockjax({url: /api\/journals/, status: 200, responseText: {
      journals: []
    }});

    // ensure  a required answer is not provided
    this.$('.authors-task input[name="authors--persons_agreed_to_be_named"]').attr('checked', false);

    // try complete again
    this.$('.authors-task button.task-completed').click();

    wait().then(() => {
      assert.mockjaxRequestNotMade('/api/tasks/1', 'PUT');
      assert.textPresent('.authors-task', 'Please fix all errors');
      assert.equal(testTask.get('completed'), false, 'task did not change completion status');
      done();
    });
  });
});

// test('adding a new author saves immediately', function(assert) {
//   let testTask = createTask();
//   this.set('testTask', testTask);
//   $('#ember-testing-container').append("<div id='ember-basic-dropdown-wormhole'></div>");
//   this.render(template);
//
//   $.mockjax({url: '/api/author', type: 'POST', status: 201, responseText: {author: {id: 1}}});
//   this.$('#add-new-author-button').click();
//   return wait().then(() => {
//     $('#add-new-individual-author-link').click();
//   }).then(wait)
//   .then(() => {
//     assert.mockjaxRequestMade('/api/authors/', 'POST');
//   });
// });
