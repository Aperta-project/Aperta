import { test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { make } from 'ember-data-factory-guy';
import moduleForComponentIntegration from 'tahi/tests/helpers/module-for-component-integration';

moduleForComponentIntegration('nested-question-textarea', {
  beforeEach() {
    this.getAnswers = function() {
      return this.container.lookup('service:store').peekAll('nested-question-answer');
    };
  }
});

test('saves on input events', function(assert) {
  let task =  make('ad-hoc-task');
  this.fakeCan.allowPermission('edit', task);
  this.createQuestion(task, 'foo');
  this.set('task', task);

  this.render(hbs`
    {{nested-question-textarea ident="foo" owner=task}}
  `);

  $.mockjax({url: '/api/nested_questions/1/answers', type: 'POST', status: 204, responseText: '{}'});
  this.$('textarea').val('new comment').trigger('input');

  return this.wait().then(() => {
    assert.mockjaxRequestMade('/api/nested_questions/1/answers', 'POST', 'it saves the new answer on input');
  });
});

test('does not save on change events', function(assert) {
  let task =  make('ad-hoc-task');
  this.fakeCan.allowPermission('edit', task);
  this.createQuestion(task, 'foo');
  this.set('task', task);

  this.render(hbs`
    {{nested-question-textarea ident="foo" owner=task}}
  `);

  $.mockjax({url: '/api/nested_questions/1/answers', type: 'POST', status: 204, responseText: '{}'});
  this.$('textarea').val('new comment').trigger('change');

  return this.wait().then(() => {
    assert.mockjaxRequestNotMade('/api/nested_questions/1/answers', 'POST', 'it saves the new answer on input');
  });
});
