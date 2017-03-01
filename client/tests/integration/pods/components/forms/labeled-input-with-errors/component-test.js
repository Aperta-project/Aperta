import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('forms/labeled-input-with-errors',
  'Integration | Component | forms | labeled input with errors', {
    integration: true
  }
);

test('it renders a label', function(assert) {
  this.render(hbs`{{forms/labeled-input-with-errors label="Fred"}}`);

  assert.textPresent('label', 'Fred');
});

test('it renders an input', function(assert) {
  this.render(hbs`{{forms/labeled-input-with-errors label="Fred"}}`);
  assert.elementFound('.form-control[type="text"]');
});

test('it shows error message if errors', function(assert) {
  this.set('errors', ['hello']);
  this.render(hbs`{{forms/labeled-input-with-errors label="Fred" errors=errors}}`);

  assert.textPresent('.error-message', 'hello');
});

test('it shows normal input if no errors', function(assert) {
  this.set('errors', null);
  this.render(hbs`{{forms/labeled-input-with-errors label="Fred" errors=errors}}`);

  assert.elementNotFound('.labeled-input-with-errors-errored');
});

test('it shows styled input if errors', function(assert) {
  this.set('errors', ['hello']);
  this.render(hbs`{{forms/labeled-input-with-errors label="Fred" errors=errors}}`);

  assert.elementFound('.labeled-input-with-errors-errored');
});
