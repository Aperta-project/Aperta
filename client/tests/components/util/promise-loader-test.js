import Ember from 'ember';
import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

const { RSVP } = Ember;

moduleForComponent('util/promise-loader', 'Integration | Component | promise loader', {
  integration: true,

  beforeEach() {
    this.template = hbs`
      {{#util/promise-loader promise=promise as |resolved|}}
        <span>resolved value is {{resolved}}</span>
      {{else}}
        loading
      {{/util/promise-loader}}
    `;
  }
});

test('no promise', function(assert) {
  assert.expect(1);

  this.render(this.template);

  assert.equal(
    this.$().text().trim(),
    'resolved value is',
    'loading state'
  );
});

test('promise unfulfilled', function(assert) {
  assert.expect(1);

  this.set('promise', new RSVP.Promise(function() {}));

  this.render(this.template);

  assert.equal(
    this.$().text().trim(),
    'loading',
    'loading state'
  );
});


test('promise fulfilled', function(assert) {
  assert.expect(1);

  this.set('promise', RSVP.resolve('done'));
  this.render(this.template);

  assert.ok(
    this.$().text().trim().match('done'),
    'promise fulfilled and yields resolved value of promise'
  );
});
