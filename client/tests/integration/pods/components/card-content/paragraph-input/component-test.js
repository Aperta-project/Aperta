import Ember from 'ember';
import { moduleForComponent, test } from 'ember-qunit';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'card-content/paragraph-input',
  'Integration | Component | card content | paragraph input',
  {
    integration: true,
    beforeEach() {
      registerCustomAssertions();
      this.set('answer', Ember.Object.create());
      this.set('content', Ember.Object.create());
    }
  }
);

let template = hbs`{{card-content/paragraph-input
answer=answer
content=content
disabled=disabled
workingValue=workingValue
}}`;

test(`it disables the by marking it read-only if disabled=true`, function(assert) {
  this.set('disabled', true);
  this.render(template);
  assert.elementFound('.read-only');
});

test(`it displays the value from answer.value`, function(assert) {
  this.set('answer', Ember.Object.create({value: 'Bar'}));
  this.render(template);
  assert.equal(this.$('.ember-text-area').val(), 'Bar', 'Text is present in textarea');
});

test('it displays error messages if present', function(assert){
  let errorsArr = ['Oh Noes', 'You fool!'];
  this.set('answer', Ember.Object.create({readyIssuesArray: errorsArr, shouldShowErrors: true}));
  this.render(template);
  assert.equal(this.$('.validation-error').length, 2, 'Two errors are present');
  assert.equal(this.$('.validation-error').eq(0).text().trim(), errorsArr[0], 'First error text matches');
  assert.equal(this.$('.validation-error').eq(1).text().trim(), errorsArr[1], 'Second error text matches');
  let text = 'Error class present on parent element';
  assert.ok(this.$('.card-content-paragraph-input').hasClass('has-error'), text);
});
