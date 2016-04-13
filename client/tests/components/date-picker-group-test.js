import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('date-picker-group', 'Component: date-picker-group', {
  integration: true,

  beforeEach() {
    this.setProperties({
      startDate: null,
      endDate: null,
      today: new Date()
    });
  }
});

test('it renders', function(assert) {
  assert.expect(1);

  this.render(hbs`
    {{#date-picker-group as |group|}}
      {{date-picker group=group
                    type="text"
                    role="startPicker"
                    date=startDate}}

      {{date-picker group=group
                    type="text"
                    role="endPicker"
                    date=endDate}}
    {{/date-picker-group}}
  `);

  assert.equal(this.$('.datepicker-field').length, 2);
});
