import { moduleForModel, test } from 'ember-qunit';
import Ember from 'ember';

moduleForModel('figure', 'Unit | Model | figure', {
  integration: true
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

  $.mockjax({url: /figures/, type: 'POST', status: 201, responseText: {figure: {id: '1'}}});

  Ember.run(() => {
    model.save();
  });
});
