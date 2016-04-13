import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('binary-radio-button', 'Integration | Component | binary radio button', {
  integration: true,

  beforeEach() {
    this.set('hungry', null);
    this.actions = {
      yesAction() { this.set('hungry', true); },
      noAction()  { this.set('hungry', false); }
    };
  }
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{binary-radio-button}}
  `);

  assert.equal(this.$('input[type=radio]').length, 2);
});

test('it updates', function(assert) {
  assert.expect(3);

  this.render(hbs`
    {{binary-radio-button name="hungry"
                          selection=hungry
                          yesAction="yesAction"
                          noAction="noAction"}}
  `);

  assert.equal(this.$('input:checked').length, 0, 'none checked');

  this.set('hungry', true);
  assert.equal(this.$('input:checked').length, 1, 'one checked');
  assert.ok(this.$('#hungry-yes').is(':checked'), 'yes is checked');
});
