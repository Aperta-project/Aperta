import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import FakeCanService from '../helpers/fake-can-service';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';

moduleForComponent('upload-manuscript-task', 'Integration | Component | manuscript upload task', {
  integration: true,

  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
    this.registry.register('service:can', FakeCanService);

    const paper = make('paper', {
      fileType: 'docx',
      publishingState: 'in_revision',
      journal: {
        pdfAllowed: true
      },
      sourceFile: null,
      versionedTexts: [{
        id: 1,
        majorVersion: 1,
        minorVersion: 1,
      }]
    });

    this.set('task', make('upload-manuscript-task', {
      completed: false,
      paper: paper
    }));
    this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
  }
});

test('it renders', function(assert) {
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', this.get('task'));

  this.render(hbs`{{upload-manuscript-task task=task}}`);
  assert.equal(this.$('.task-main-content').length, 1, 'body is displayed');
});

test('No upload sourcefile component for docx', function(assert) {
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', this.get('task'));

  this.render(hbs`{{upload-manuscript-task task=task}}`);
  assert.equal(this.$('#upload-sourcefile').length, 0, 'Upload sourcefile component doesn\'t render');
});

test('Upload sourcefile component renders for pdf', function(assert) {
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', this.get('task'));

  this.set('task.paper.fileType', 'pdf');

  this.render(hbs`{{upload-manuscript-task task=task}}`);
  assert.equal(this.$('#upload-sourcefile').length, 1, 'Upload sourcefile component does render');
});

test('docx papers don\'t require sourcefiles', function(assert) {
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', this.get('task'));
  $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});

  this.render(hbs`{{upload-manuscript-task task=task}}`);
  this.$('button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.equal(this.get('task.completed'), true, 'task was completed');
    assert.mockjaxRequestMade('/api/tasks/1', 'PUT');
    done();
  });
});

test('pdf papers display a validation error if no sourcefile is attached', function(assert) {
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', this.get('task'));
  $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});

  this.render(hbs`{{upload-manuscript-task task=task}}`);
  this.set('task.paper.fileType', 'pdf');
  this.$('button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.equal(this.get('task.completed'), false, 'task did not complete');
    assert.mockjaxRequestMade('/api/tasks/1', 'PUT');
    assert.equal(this.$('.error-message').length, 2);
    assert.equal(this.$('.error-message:contains("Please upload your source file")').length, 1);
    done();
  });
});

test('pdf papers validate if a sourcefile is attached', function(assert) {
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', this.get('task'));
  $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});

  this.render(hbs`{{upload-manuscript-task task=task}}`);
  this.set('task.paper.fileType', 'pdf');
  this.set('task.paper.sourcefile', 'some.file');
  this.$('button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.equal(this.get('task.completed'), true, 'task was completed');
    assert.mockjaxRequestMade('/api/tasks/1', 'PUT');
    done();
  });
});

test('pdf papers not in revision don\'t require sourcefiles', function(assert) {
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', this.get('task'));
  $.mockjax({url: '/api/tasks/1', type: 'PUT', status: 204, responseText: '{}'});
  this.set('task.paper.fileType', 'pdf');
  this.set('task.paper.versionedTexts', []);
  this.set('task.paper.publishingState', '');

  this.render(hbs`{{upload-manuscript-task task=task}}`);
  this.$('button.task-completed').click();

  let done = assert.async();
  wait().then(() => {
    assert.equal(this.get('task.completed'), true, 'task was completed');
    assert.mockjaxRequestMade('/api/tasks/1', 'PUT');
    done();
  });
});
