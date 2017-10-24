import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import wait from 'ember-test-helpers/wait';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'paper-attachment-manager',
  'Integration | Component | paper attachment manager',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      manualSetup(this.container);

      this.registry.register(
        'service:pusher',
        Ember.Object.extend({ socketId: 'foo' })
      );
    },
    afterEach() {
      $.mockjax.clear();
    }
  }
);

test(`deleting an errored file posts to destroy the file`, function(assert) {
  this.set(
    'task',
    make('upload-manuscript-task', {
      paper: {
        file: { status: 'error' }
      }
    })
  );

  this.set('attachmentType', 'manuscript');
  this.render(
    hbs`{{paper-attachment-manager attachmentType=attachmentType task=task disabled=false}}`
  );

  let mockUrl = `/api/tasks/${this.get('task.id')}/delete_manuscript`;
  let mockInfo = { url: mockUrl, type: 'DELETE', status: 204 };
  $.mockjax(mockInfo);

  assert.textPresent('.error-message', 'There was an error');
  assert.elementFound('.upload-cancel-button');
  this.$('.upload-cancel-button').click();
  return wait().then(() => {
    assert.mockjaxRequestMade(mockUrl, 'DELETE');
  });
});

test(`deleting a sourcefile uses a different endpoint`, function(assert) {
  this.set(
    'task',
    make('upload-manuscript-task', {
      paper: {
        sourcefile: { status: 'error' }
      }
    })
  );

  this.set('attachmentType', 'sourcefile');
  this.render(
    hbs`{{paper-attachment-manager attachmentType=attachmentType task=task disabled=false}}`
  );

  let mockUrl = `/api/tasks/${this.get('task.id')}/delete_sourcefile`;
  let mockInfo = { url: mockUrl, type: 'DELETE', status: 204 };
  $.mockjax(mockInfo);

  assert.textPresent('.error-message', 'There was an error');
  assert.elementFound('.upload-cancel-button');
  this.$('.upload-cancel-button').click();
  return wait().then(() => {
    assert.mockjaxRequestMade(mockUrl, 'DELETE');
  });
});
