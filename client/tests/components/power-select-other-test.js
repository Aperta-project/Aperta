import {
  moduleForComponent,
  test
} from 'ember-qunit';

import {
  mousedown as powerSelectFocus, mouseup as powerSelectChoose
} from 'tahi/lib/power-select-event-trigger';

import Ember from 'ember';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('power-select-other', 'Integration | Component | power select other', {
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

  assert.equal(this.$('.ember-power-select-trigger').length, 1, 'select renders');
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

test('input displayed when other option is selected', function(assert) {
  assert.expect(2);
  this.set('nameValue', 'Gena');

  this.render(hbs`
    <span id="selected-name">{{nameValue}}</span>
    {{power-select-other options=names value=nameValue}}
  `);

  assert.equal(
    this.$('input').length,
    1,
    'input is visible'
  );


  Ember.run(() => {
    powerSelectFocus(this.$('.ember-power-select-trigger'));
  });

  Ember.run(() => {
    powerSelectChoose($('.ember-power-select-option:contains("John")'));
  });

  Ember.run(() => {
    assert.equal(
      this.$('#selected-name').text().trim(),
      'John',
      'value property is changed'
    );
  });
});

test('other formatting is available', function(assert) {
  assert.expect(1);
  this.set('nameValue', 'Gena');

  this.render(hbs`
    <span id="selected-name">{{nameValue}}</span>
    {{power-select-other options=names
                         value=nameValue
                         allowOtherFormatting=true}}
  `);

  assert.equal(
    this.$('.format-input').length,
    1,
    'format-input is visible'
  );
});
