import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

function selectElementText(el) {
  const range = document.createRange();
  range.selectNodeContents(el);

  const sel = window.getSelection();
  sel.removeAllRanges();
  sel.addRange(range);
}


moduleForComponent('format-input', 'Component: format-input', {
  integration: true,

  beforeEach() {
    this.set('title', 'Title');
  }
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{format-input value=title}}
  `);

  assert.equal(this.$('.format-input').length, 1);
});

test('value is displayed', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{format-input value=title}}
  `);

  assert.equal(this.$('.format-input-field').html().trim(), 'Title');
});

test('value is formatted with bold', function(assert) {
  assert.expect(2);

  this.render(hbs`
    {{format-input value=title}}
  `);

  assert.equal(
    this.$('.format-input-field').html().trim(),
    'Title',
    'Value is unformatted'
  );

  selectElementText(this.$('.format-input-field').get(0));
  this.$('.format-input-button:last').click();

  assert.equal(
    this.$('.format-input-field').html().trim(),
    '<b>Title</b>',
    'Value is formatted'
  );
});
