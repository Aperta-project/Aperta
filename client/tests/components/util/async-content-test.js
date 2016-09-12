import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('util/async-content', 'Integration | Component | async content', {
  integration: true,

  beforeEach() {
    this.template = hbs`
      {{#util/async-content task=task as |resolved|}}
        <span>resolved value is {{resolved}}</span>
      {{else}}
        loading
      {{/util/async-content}}
    `;
  }
});

test('yields the task\'s last completed value', function(assert) {
  assert.expect(1);

  this.set( 'task', {perform: () => {}, lastSuccessful: {value: 'done'}});

  this.render(this.template);

  assert.ok(
    this.$().text().trim().match('done'),
    'task complete and yields returned value of promise'
  );
});

test('renders the else state if the task is not completed with a value', function(assert) {
  assert.expect(1);

  this.set( 'task', {perform: () => {} });

  this.render(this.template);

  assert.equal(
    this.$().text().trim(),
    'loading',
    'loading state'
  );
});
