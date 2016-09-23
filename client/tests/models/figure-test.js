import { moduleForModel, test } from 'ember-qunit';
import Ember from 'ember';

moduleForModel('figure', 'Unit | Model | figure', {
  needs: [
    'model:paper',
    'model:author',
    'model:group-author',
    'model:collaboration',
    'model:comment-look',
    'model:decision',
    'model:discussion-topic',
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
  assert.expect(1);
  const start = assert.async();
  let mockPaper = {
    reload() { assert.ok(true, 'reload called'); start();}
  };
  const model = this.subject();
  model.paper = mockPaper;
  Ember.run(() => {
    model.destroyRecord();
  });
});

test('makes its paper reload when it is saved', function(assert) {
  assert.expect(1);
  const start = assert.async();
  let mockPaper = {
    reload() { assert.ok(true, 'reload called'); start();}
  };
  const model = this.subject();
  model.paper = mockPaper;

  $.mockjax({url: /figures/, type: 'POST', status: 204, responseText: {}});

  Ember.run(() => {
    model.save();
  });
});
