import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('show-if-editing', 'Integration | Component | show if editing', {
  integration: true,

  beforeEach() {
    this.set('empty', true);
  }
});

test('it renders', function(assert) {
  assert.expect(4);

  this.set('startFunction', function() { assert.ok(true, 'start action called'); });
  this.set('stopFunction',  function() { assert.ok(true, 'stop action called'); });

  this.render(hbs`
    {{#show-if-editing initialState=empty
                       startEditingCallback=startFunction
                       stopEditingCallback=stopFunction
                       as |editing start stop|}}
      {{#if editing}}
        <div class="text">EDITING</div>
        <span {{action stop}}>Stop</span>
      {{else}}
        <div class="text">NOT EDITING</div>
        <span {{action start}}>Start</span>
      {{/if}}
    {{/show-if-editing}}
  `);

  assert.equal(this.$('.text').text().trim(), 'EDITING', 'In editing state');
  this.$('span').click();
  assert.equal(this.$('.text').text().trim(), 'NOT EDITING', 'Not in editing state');
  this.$('span').click();
});
