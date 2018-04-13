/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

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
      this.registry.register(
        'service:pusher',
        Ember.Object.extend({ socketId: 'foo' })
      );
      this.set('dirtyEditorConfig', {model: 'card', properties: ['xml']});
    },

    afterEach() {
      $.mockjax.clear();
    }
  }
);

test('publishing requires confirmation and a history entry', function(assert) {
  assert.expect(4);
  let card = make('card', { state: 'draft' });
  this.set('card', card);

  $.mockjax({
    url: `/api/cards/${card.id}/publish`,
    method: 'PUT',
    status: 204
  });

  $.mockjax({
    url: `/api/cards/${card.id}`,
    method: 'GET',
    status: 200,
    responseText: {
      cards: [{ id: card.id }]
    }
  });
  this.render(
    hbs`
<div id='overlay-drop-zone'></div>
<div id='card-editor-action-buttons'></div>
{{card-editor/editor card=card dirtyEditorConfig=dirtyEditorConfig}}`
  );

  assert.elementFound('.editor-publish');
  this.$('.editor-publish').click();
  assert.elementFound(
    '.publish-card-overlay .button-primary[disabled]',
    'the confirm button is disabled'
  );
  this.$('.publish-history-entry').val('My reason for changes').change();
  this.$('.publish-card-overlay .button-primary').click();

  return wait().then(() => {
    assert.mockjaxRequestMade(
      {
        url: `/api/cards/${card.id}/publish`,
        type: 'PUT',
        data: '{"historyEntry":"My reason for changes"}'
      },
      'it posts to publish the card with the history entry'
    );
    assert.mockjaxRequestMade(
      `/api/cards/${card.id}`,
      'GET',
      'it reloads the card'
    );
  });
});

test('archiving requires confirmation', function(assert) {
  assert.expect(5);
  let card = make('card', { state: 'draft', journal: { id: 1 } });
  this.set('card', card);

  this.set('fakeRouting', {
    transitionTo(route, modelId, _whatever) { //eslint-disable-line no-unused-vars
      assert.equal(
        route,
        'admin.journals.cards',
        'transitions to the card catalog'
      );
      assert.equal(
        modelId,
        1,
        `sets the query param to the card's journal id`
      );
    }
  });

  $.mockjax({
    url: `/api/cards/${card.id}/archive`,
    method: 'PUT',
    status: 204
  });

  $.mockjax({
    url: `/api/cards/${card.id}`,
    method: 'GET',
    status: 200,
    responseText: {
      cards: [{ id: card.id }]
    }
  });
  this.render(
    hbs`
<div id='overlay-drop-zone'></div>
<div id='card-editor-action-buttons'></div>
{{card-editor/editor card=card dirtyEditorConfig=dirtyEditorConfig routing=fakeRouting}}`
  );

  assert.elementFound('.editor-archive[disabled]', 'archive is disabled for drafts');
  this.set('card.state', 'published');
  this.$('.editor-archive').click();
  assert.elementFound('.publish-card-overlay.archive .button-primary');
  this.$('.publish-card-overlay.archive .button-primary').click();

  return wait().then(() => {
    assert.mockjaxRequestMade(
      `/api/cards/${card.id}/archive`,
      'PUT',
      'it posts to archive the card'
    );
  });
});

test('saving is enabled when the card xml is dirty', function(assert) {
  let card = make('card', { state: 'draft', xml: 'Foo' });
  this.set('card', card);

  this.render(
    hbs`
<div id='card-editor-action-buttons'></div>
{{card-editor/editor card=card dirtyEditorConfig=dirtyEditorConfig}}`
  );
  assert.elementFound(
    '.editor-save[disabled]',
    'the button is initially disabled'
  );
  this.set('card.xml', 'Bar');
  assert.ok(
    !$('.editor-save').attr('disabled'),
    'the button is enabled when the xml is dirty'
  );
});

test('deleting is disabled when the card xml is dirty', function(assert) {
  let card = make('card', { state: 'draft', xml: 'Foo' });
  this.set('card', card);

  this.render(
    hbs`
<div id='card-editor-action-buttons'></div>
{{card-editor/editor card=card dirtyEditorConfig=dirtyEditorConfig}}`
  );
  assert.elementNotFound(
    '.editor-delete[disabled]',
    'the button is initially enabled'
  );
  this.set('card.xml', 'Bar');
  assert.ok(
    $('.editor-delete').attr('disabled'),
    'the button is disabled when the xml is dirty'
  );
});

test('deletion button is only present when the card is a draft', function(assert) {
  let card = make('card', { state: 'published' });
  this.set('card', card);

  this.render(
    hbs`
<div id='card-editor-action-buttons'></div>
{{card-editor/editor card=card dirtyEditorConfig=dirtyEditorConfig}}`
  );
  assert.elementNotFound('.editor-delete',
                         'the delete button is not present when not a draft');

  this.set('card.state', 'draft');
  assert.elementFound('.editor-delete',
                      'the delete button is present when a draft');
});

test('deleting requires confirmation', function(assert) {
  assert.expect(4);
  let card = make('card', { state: 'draft', journal: { id: 1 } });
  this.set('card', card);

  this.set('fakeRouting', {
    transitionTo(route, modelId, _whatever) { //eslint-disable-line no-unused-vars
      assert.equal(
        route,
        'admin.journals.cards',
        'transitions to the card catalog'
      );
      assert.equal(
        modelId,
        1,
        `sets the query param to the card's journal id`
      );
    }
  });

  $.mockjax({
    url: `/api/cards/${card.id}`,
    method: 'DELETE',
    status: 204
  });

  $.mockjax({
    url: `/api/cards/${card.id}`,
    method: 'GET',
    status: 200,
    responseText: {
      cards: [{ id: card.id }]
    }
  });
  this.render(
    hbs`
      <div id='overlay-drop-zone'></div>
      <div id='card-editor-action-buttons'></div>
      {{card-editor/editor card=card dirtyEditorConfig=dirtyEditorConfig routing=fakeRouting}}`
  );

  this.$('.editor-delete').click();
  assert.elementFound('.publish-card-overlay.delete .button-primary');
  this.$('.publish-card-overlay.delete .button-primary').click();

  return wait().then(() => {
    assert.mockjaxRequestMade(
      `/api/cards/${card.id}`,
      'DELETE',
      'it deletes the card'
    );
  });
});

test('reversion button is only present when the card is published with changes and reverts card', function(assert) {
  assert.expect(6);

  let card = make('card', { xml: '', state: 'published' });
  this.set('card', card);

  this.render(
    hbs`
      <div id='overlay-drop-zone'></div>
      <div id='card-editor-action-buttons'></div>
      {{card-editor/editor card=card dirtyEditorConfig=dirtyEditorConfig}}`
  );

  assert.elementNotFound('.editor-revert',
                         'the revert button is not present when card is not publishedWithChanges');

  this.set('card.state', 'publishedWithChanges');
  assert.elementFound('.editor-revert',
                      'the revert button is present when card is publishedWithChanges');

  this.set('card.xml', 'Bar');
  assert.equal($('.editor-revert').attr('disabled'), 'disabled',
                      'the revert button is disabled with dirty xml');

  this.set('card.xml', '');
  assert.equal($('.editor-revert').attr('disabled'), undefined,
                      'the revert button is enabled without dirty xml');

  this.$('button.editor-revert').click();
  assert.elementFound('.publish-card-overlay.revert .button-primary');

  $.mockjax({
    url: `/api/cards/${card.id}/revert`,
    method: 'PUT',
    status: 204
  });

  this.$('.publish-card-overlay.revert .button-primary').click();

  return wait().then(() => {
    assert.mockjaxRequestMade(
      `/api/cards/${card.id}/revert`,
      'PUT',
      'it reverts the card'
    );
  });
});

test('xml validation errors appear if errors are present', function(assert) {
  assert.expect(9);

  let card = make('card', { xml: '', state: 'draft' });
  this.set('card', card);

  // check for absence of error panel as initial state

  this.set('errors', []);

  this.render(
    hbs`
      <div id='card-editor-action-buttons'></div>
      {{card-editor/editor card=card dirtyEditorConfig=dirtyEditorConfig routing=fakeRouting errors=errors}}`
  );

  let displayedErrorsPre = $('[data-test-selector="xml-error"]');
  assert.elementNotFound('.card-editor-xml-errors',
    'xml error panel not visible when errors absent');
  assert.elementNotFound('.error-message',
    'xml error header not visible when errors absent');
  assert.equal(displayedErrorsPre.length, 0,
    'itemized xml errors not visible when errors absent');

  // check for presence of error panel when errors exist

  const mockErrors = [
      {detail: {message: 'this is a test error message #1', line: 2, col: 90}},
      {detail: {message: 'this is a test error message #2', line: 3, col: 91}}];

  this.set('errors', mockErrors);

  this.render(
    hbs`
      <div id='card-editor-action-buttons'></div>
      {{card-editor/editor card=card dirtyEditorConfig=dirtyEditorConfig routing=fakeRouting errors=errors}}`
  );

  let displayedErrorsPost = $('[data-test-selector="xml-error"]');
  assert.elementFound('.card-editor-xml-errors',
    'xml error panel visible when errors present');
  assert.elementFound('.error-message',
    'xml error header visible when errors present');
  assert.equal(displayedErrorsPost.length, 2,
    'itemized xml errors visible when errors present');

  const mockActiveModelErrors = [
    {detail: {message: 'this is a test error message #1'}}];

  this.set('errors', mockActiveModelErrors);

  this.render(
    hbs`
      <div id='card-editor-action-buttons'></div>
      {{card-editor/editor card=card dirtyEditorConfig=dirtyEditorConfig routing=fakeRouting errors=errors}}`
  );

  displayedErrorsPost = $('[data-test-selector="xml-error"]');
  assert.elementFound('.card-editor-xml-errors',
    'xml error panel visible when errors present');
  assert.elementFound('.error-message',
    'xml error header visible when errors present');
  assert.equal(displayedErrorsPost.length, 1,
    'itemized xml errors visible when errors present');
});
