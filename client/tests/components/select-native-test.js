import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs   from 'htmlbars-inline-precompile';

moduleForComponent('select-native', 'SelectNativeComponent', {
  integration: true,

  beforeEach() {
    this.set('people', [
      { id: 1, name: 'Bob Joe' },
      { id: 2, name: 'Joe Bob' }
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

test('it displays a list', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{select-native content=people
                    optionValuePath="id"
                    optionLabelPath="name"}}
  `);

  assert.equal(this.$('option').length, 2, 'list is rendered');
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

