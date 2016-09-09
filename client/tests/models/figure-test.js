import { moduleForModel, test } from 'ember-qunit';
import sinon from 'sinon';

moduleForModel('figure', 'Unit | Model | figure', {
  needs: [
    'model:paper',
    'model:author',
    'model:group-author',
    'model:collaboration',
    'model:comment-look',
    'model:decision',
    'model:discussion-topic',
    'model:bibitem',
    'model:journal',
    'model:phase',
    'model:supporting-information-file',
    'model:versioned-text',
    'model:snapshot',
    'model:task',
    'model:paper-task-type',
    'model:related-article',
    'model:user'
  ]
});

test('makes its paper reload when it is deleted', function(assert) {
  const model = this.subject();
  assert.ok(!!model);
  const mock = sinon.mock(model);
  const reload = mock.expects('reloadPaper');

  const start = assert.async();
  Ember.run(() => {
    model.destroyRecord().then(() => {
      assert.ok(reload.called, 'The paper\'s reload() should have been called');
      start();
    });
  });
});

test('makes its paper reload when it is saved', function(assert) {
  const model = this.subject();
  assert.ok(!!model);
  const mock = sinon.mock(model);
  const reload = mock.expects('reloadPaper');

  $.mockjax({url: /figures/, type: 'POST', status: 204, responseText: {}});

  const start = assert.async();
  Ember.run(() => {
    model.save().then(() => {
      assert.ok(reload.called, 'The paper\'s reload() should have been called');
      start();
    });
  });
});
