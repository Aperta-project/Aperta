import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('select-box', 'SelectBox', {
  integration: true,

  beforeEach() {
    this.set('people', [
      { name: 'Bob Joe' },
      { name: 'Joe Bob' }
    ]);

    this.set('selectedPerson', null);

    this.actions = {
      selectPerson(person) { this.set('selectedPerson', person); },
      clearPerson() { this.set('selectedPerson', null); },
    };
  }
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{#select-box items=people
                  selectedItem=selectedPerson
                  makeSelection=(action "selectPerson")
                  clearSelection=(action "clearPerson")
                  as |user|}}
      {{user.name}}
    {{/select-box}}
  `);

  assert.equal(this.$('.select-box').length, 1);
});

test('it displays a list', function(assert) {
  assert.expect(2);

  let name = this.get('people.lastObject').name;

  this.render(hbs`
    {{#select-box items=people
                  selectedItem=selectedPerson
                  makeSelection=(action "selectPerson")
                  clearSelection=(action "clearPerson")
                  as |user|}}
      {{user.name}}
    {{/select-box}}
  `);

  this.$('.select-box-element').click();

  assert.equal(this.$('.select-box-list').length, 1, 'list is rendered');

  assert.equal(
    this.$('.select-box-item:last').text().trim(),
    name,
    'item in list'
  );
});

test('it displays a placeholder', function(assert) {
  assert.expect(4);

  let name = this.get('people.lastObject').name;
  let placeholderText = 'Please select a person';

  this.render(hbs`
    {{#select-box items=people
                  selectedItem=selectedPerson
                  placeholder="Please select a person"
                  allowDeselect=true
                  makeSelection=(action "selectPerson")
                  clearSelection=(action "clearPerson")
                  as |user|}}
      {{user.name}}
    {{/select-box}}
  `);

  assert.equal(
    this.$('.select-box-element').text().trim(),
    placeholderText,
    'Placeholder displayed in select-element with no selection'
  );

  this.$('.select-box-element').click();

  assert.equal(
    this.$('.select-box-item:first').text().trim(),
    placeholderText,
    'placeholder is first item in list (allowDeselect=true)'
  );

  this.$('.select-box-item:last').click();

  assert.equal(
    this.$('.select-box-element').text().trim(),
    name,
    'Selected person is displayed in select-element'
  );

  this.$('.select-box-element').click();
  this.$('.select-box-item:first').click();

  assert.equal(
    this.$('.select-box-element').text().trim(),
    placeholderText,
    'Placeholder displayed after clearing selection'
  );
});
