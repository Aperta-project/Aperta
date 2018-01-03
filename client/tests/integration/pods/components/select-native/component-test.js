import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('select-native', 'Integration | Component | select native', {
  integration: true,

  beforeEach() {
    this.set('people', [
      { id: 1, name: 'Bob Joe' },
      { id: 2, name: 'Joe Bob' }
    ]);

    this.set('peopleArray', [
      'Bob Joe',
      'Joe Bob'
    ]);

    this.set('selectedPerson', null);
  }
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{select-native content=people
                    optionValuePath="id"
                    optionLabelPath="name"}}
  `);

  assert.equal(this.$('select').length, 1);
});

test('it displays a hash data source', function(assert) {
  assert.expect(3);
  let lastPersonId   = this.get('people.lastObject.id');
  let lastPersonName = this.get('people.lastObject.name');

  this.render(hbs`
    {{select-native content=people
                    optionValuePath="id"
                    optionLabelPath="name"}}
  `);

  assert.equal(this.$('option').length, 2, 'list is rendered');
  assert.equal(this.$('option:last').val(), lastPersonId, 'value is rendered');
  assert.equal(this.$('option:last').text().trim(), lastPersonName, 'label is rendered');
});

test('it displays an array data source', function(assert) {
  assert.expect(3);
  let lastPersonName = this.get('people.lastObject.name');

  this.render(hbs`
    {{select-native content=peopleArray}}
  `);

  assert.equal(this.$('option').length, 2, 'list is rendered');
  assert.equal(this.$('option:last').text().trim(), lastPersonName, 'value is rendered');
  assert.equal(this.$('option:last').val(), lastPersonName, 'label is rendered');
});

test('it fires the default action on-change', function(assert) {
  assert.expect(1);
  let lastPersonName = this.get('people.lastObject.name');

  this.render(hbs`
    <div id="selected-person">{{selectedPerson.name}}</div>
    {{select-native content=people
                    optionValuePath="id"
                    optionLabelPath="name"
                    selection=selectedPerson
                    action=(action (mut selectedPerson))}}
  `);

  this.$('select')[0].selectedIndex = 1;
  this.$('option:last').trigger('change');

  assert.equal(this.$('#selected-person').text().trim(), lastPersonName, 'value is changed');
});

test('it displays a prompt', function(assert) {
  assert.expect(2);

  this.render(hbs`
    {{select-native content=people
                    prompt="Hello"
                    optionValuePath="id"
                    optionLabelPath="name"}}
  `);

  assert.equal(this.$('option:first').val(), 'Hello', 'prompt is rendered');
  assert.equal(this.$('option:first').is(':disabled'), true, 'prompt is disabled');
});

test('it clears selection when prompt is selected', function(assert) {
  assert.expect(2);
  let lastPersonName = this.get('people.lastObject.name');

  this.render(hbs`
    <div id="selected-person">{{selectedPerson.name}}</div>
    {{select-native content=people
                    optionValuePath="id"
                    optionLabelPath="name"
                    prompt="Please select a person"
                    allowDeselect=true
                    selection=selectedPerson
                    action=(action (mut selectedPerson))}}
  `);

  this.$('select')[0].selectedIndex = 2;
  this.$('option:last').trigger('change');

  assert.equal(this.$('#selected-person').text().trim(), lastPersonName, 'value is changed');

  this.$('select')[0].selectedIndex = 0;
  this.$('option:first').trigger('change');

  assert.equal(this.$('#selected-person').text().trim(), '', 'value is cleared');
});
