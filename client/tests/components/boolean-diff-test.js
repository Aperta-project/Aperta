import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerDiffAssertions from 'tahi/tests/helpers/diff-assertions';

moduleForComponent('boolean-diff',
                   'Integration | Component | boolean diff',
                   {integration: true,
                    beforeEach: function() {
                      registerDiffAssertions();
                    }});

var template = hbs`{{boolean-diff
                      viewingBool=booleanToView
                      comparisonBool=booleanToCompare}}`;

test("displays no diff when same value", function(assert) {
  this.set('booleanToView', true);
  this.set('booleanToCompare', true);

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 0, 'Has removed diff spans');
});

test("displays diff when value changed", function(assert) {
  this.set('booleanToView', true);
  this.set('booleanToCompare', false);

  this.render(template);
  assert.diffPresent('No', 'Yes');
});

test("displays no diff when comparing boolean is null", function(assert) {
  this.set('booleanToView', true);
  this.set('booleanToCompare', null);

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 0, 'Has removed diff spans');
});

test("displays boolean removed when original viewing boolean is null", function(assert) {
  this.set('booleanToView', null);
  this.set('booleanToCompare', true);

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 1, 'Has removed diff spans');
});

test("displays boolean removed when original viewing boolean is undefined", function(assert) {
  this.set('booleanToView', undefined);
  this.set('booleanToCompare', true);

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 1, 'Has removed diff spans');
});
