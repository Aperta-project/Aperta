import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('power-select-other', 'PowerSelectOtherComponent', {
  integration: true,

  beforeEach() {
    this.setProperties({
      nameValue: null,
      names: ['Felix', 'Sara', 'John']
    });
  }
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{power-select-other options=names value=nameValue}}
  `);

  assert.equal(this.$('.ember-power-select').length, 1, 'select renders');
});

test('initial value is selected', function(assert) {
  assert.expect(1);
  this.set('nameValue', 'Sara');

  this.render(hbs`
    {{power-select-other options=names value=nameValue}}
  `);

  assert.equal(
    this.$('.ember-power-select-trigger').text().trim(),
    'Sara',
    'initial value is selected'
  );
});

test('other option is selected', function(assert) {
  assert.expect(3);
  this.set('nameValue', 'Gena');

  this.render(hbs`
    <span id="selected-name">{{nameValue}}</span>
    {{power-select-other options=names value=nameValue}}
  `);

  assert.equal(
    this.$('.ember-power-select-trigger').text().trim(),
    'other...',
    'other option is selected'
  );

  assert.equal(
    this.$('.format-input').length,
    1,
    'format-input is visible'
  );

  Ember.run(() => {
    this.$('.ember-power-select-trigger').mousedown();
  });

  Ember.run(() => {
    $('.ember-power-select-option:contains("John")').mouseup();
  });

  Ember.run(() => {
    assert.equal(
      this.$('#selected-name').text().trim(),
      'John',
      'value property is changed'
    );
  });
});
