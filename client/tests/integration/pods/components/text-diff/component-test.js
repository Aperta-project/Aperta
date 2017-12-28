import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import registerDiffAssertions from 'tahi/tests/helpers/diff-assertions';

moduleForComponent('text-diff',
                   'Integration | Component | text diff',
                   {integration: true,
                    beforeEach: function() {
                      registerDiffAssertions();
                    }});

var template = hbs`{{text-diff
                      viewingText=textViewed
                      comparisonText=textCompared}}`;

test("displays no diff when same value", function(assert) {
  this.set('textViewed', 'Science is cool!');
  this.set('textCompared', 'Science is cool!');

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 0, 'Has removed diff spans');
});

test("displays diff when value has changed", function(assert) {
  this.set('textViewed', 'Science is cool!');
  this.set('textCompared', 'Science is AWESOME!');

  this.render(template);
  assert.diffPresent('Science is AWESOME!', 'Science is cool!');
});

test("displays text added when comparing text is null", function(assert) {
  this.set('textViewed', 'Science is cool!');
  this.set('textCompared', null);

  this.render(template);
  assert.equal(this.$('.added').length, 1, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 0, 'Has removed diff spans');
});

test("displays text removed when comparing text is null", function(assert) {
  this.set('textViewed', null);
  this.set('textCompared', 'Science is AWESOME!');

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 1, 'Has removed diff spans');
});

test("displays text added when comparing text is undefined", function(assert) {
  this.set('textViewed', 'Science is cool!');
  this.set('textCompared', undefined);

  this.render(template);
  assert.equal(this.$('.added').length, 1, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 0, 'Has removed diff spans');
});

test("displays text added when comparing text is undefined", function(assert) {
  this.set('textViewed', undefined);
  this.set('textCompared', 'Science is AWESOME!');

  this.render(template);
  assert.equal(this.$('.added').length, 0, 'Has no added diff spans');
  assert.equal(this.$('.removed').length, 1, 'Has removed diff spans');
});
