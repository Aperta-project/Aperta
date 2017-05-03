import { moduleForComponent, test } from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import wait from 'ember-test-helpers/wait';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent(
  'card-editor/editor',
  'Integration | Component | card editor | editor',
  {
    integration: true,

    beforeEach() {
      registerCustomAssertions();
      manualSetup(this.container);
      this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
    },

    afterEach() {
      $.mockjax.clear();
    }
  }
);

test('publishing requires confirmation', function(assert) {
  assert.expect(4);
  let card = make('card', { state: 'draft' });
  this.set('card', card);

  $.mockjax({
    url: `/api/cards/${card.id}/publish`,
    method: 'PUT',
    status: 204,
  });

  $.mockjax({
    url: `/api/cards/${card.id}`,
    method: 'GET',
    status: 200,
    responseText: {
      cards: [{id: card.id}]
    }
  });
  this.render(
    hbs`
<div id='overlay-drop-zone'></div>
{{card-editor/editor card=card}}`
  );

  assert.elementFound('.editor-publish');
  this.$('.editor-publish').click();
  assert.elementFound('.publish-card-overlay .button-primary');
  this.$('.publish-card-overlay .button-primary').click();

  return wait().then(() => {
    assert.mockjaxRequestMade(
      `/api/cards/${card.id}/publish`,
      'PUT',
      'it posts to publish the card'
    );
    assert.mockjaxRequestMade(
      `/api/cards/${card.id}`,
      'GET',
      'it reloads the card'
    );
  });
});

test('saving is enabled when the card xml is dirty', function(assert) {
  let card = make('card', { state: 'draft', xml: 'Foo' });
  this.set('card', card);

  this.render(hbs`{{card-editor/editor card=card}}`);
  assert.elementFound(
    '.editor-save[disabled]',
    'the button is initially disabled'
  );
  this.set('card.xml', 'Bar');
  assert.ok(!$('.editor-save').attr('disabled'),
    'the button is enabled when the xml is dirty'
  );
});
