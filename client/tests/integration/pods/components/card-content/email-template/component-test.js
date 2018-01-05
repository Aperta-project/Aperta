import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';
import testQAIdent from 'tahi/tests/helpers/test-mixins/qa-ident';

moduleForComponent(
  'card-content/email-template',
  'Integration | Component | card content | email-template',
  {
    integration: true,

    beforeEach() {
      this.set('owner', Ember.Object.create({ id: 1 }));
      this.set('content', Ember.Object.create({ letterTemplate: 'test' }));
    },

    afterEach() {
      $.mockjax.clear();
    }
  }
);

const template = hbs`{{card-content/email-template
content=content
owner=owner
}}`;

const templateJSON = '{"letter_template": {"body": "<p>test</p>"}}';

test(`it displays the body of the template as markup`, function(assert) {
  $.mockjax({url: '/api/tasks/1/render_template', type: 'PUT', status: 201, responseText: templateJSON});
  this.render(template);
  assert.elementFound('.card-content-template');

  return wait().then(() => {
    assert.textPresent('.card-content-template p', 'test');
    assert.textNotPresent('.card-content-template p', '<p>test</p>');
  });
});

testQAIdent(template);
