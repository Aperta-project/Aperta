import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';

moduleForComponent(
  'card-content/template',
  'Integration | Component | card content | template',
  {
    integration: true,
    beforeEach() {
      this.set('actionStub', function() {});
      this.set('owner', Ember.Object.create({ id: 1 }));
      this.set('content', Ember.Object.create({ letterTemplateident: 'test' }));
    }
  }
);

let template = hbs`{{card-content/template
content=content
disabled=disabled
owner=owner
answer=answer
preview=preview
valueChanged=(action actionStub)
}}`;

test(`it displays the body of the template as markup`, function(assert) {
  $.mockjax({url: '/api/tasks/1/render_template', type: 'PUT', status: 201, responseText: '{"body": "<p>test</p>"}'});
  this.render(template);
  assert.elementFound('.card-content-template');

  return wait().then(() => {
    assert.textPresent('.card-content-template p', 'test');
    assert.textNotPresent('.card-content-template p', '<p>test</p>');
  });
});
