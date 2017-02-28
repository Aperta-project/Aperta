import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import FakeCanService from '../helpers/fake-can-service';

moduleForComponent('upload-manuscript-task', 'Integration | Component | manuscript upload task', {
  integration: true,

  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
    this.registry.register('service:can', FakeCanService);

    this.set('task', make('upload-manuscript-task', {
      completed: false,
      paper: {
        fileType: 'docx',
        journal: {
          pdfAllowed: true
        }
      }
    }));
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
