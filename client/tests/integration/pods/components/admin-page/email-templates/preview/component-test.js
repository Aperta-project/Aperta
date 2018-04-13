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
import hbs from 'htmlbars-inline-precompile';
import { manualSetup } from 'ember-data-factory-guy';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';
import FactoryGuy from 'ember-data-factory-guy';

moduleForComponent('admin-page/email-templates/preview',
  'Integration | Component | Admin Page | Email Templates | Preview', {
    integration: true,
    beforeEach() {
      manualSetup(this.container);
    },
    afterEach() {
      $.mockjax.clear();
    }
  }
);

test('it displays template errors properly', function(assert) {
  let template = FactoryGuy.make('letter-template', {subject: 'foo', body: 'bar'});
  this.set('template', template);

  $.mockjax({
    url: `/api/admin/letter_templates/${template.get('id')}/preview`,
    status: 422,
    responseText: { errors: [] }
  });
  this.set('dirtyEditorConfig', {model: 'template', properties: ['subject', 'body']});

  // Test display of errors through email-template/edit component
  this.render(hbs`
    {{admin-page/email-templates/edit template=template dirtyEditorConfig=dirtyEditorConfig}}
  `);

  this.$("[data-test-selector='preview-email']").click();

  return wait().then(() => {
    assert.equal(this.$('.text-danger').text().trim(), 'Please correct errors where indicated.', 'Displays errors if preview template has syntax errors');
  });
});

test('it displays dummy data when clicked on preview button', function(assert) {
  let template = FactoryGuy.make('letter-template', {subject: 'foo', body: 'bar'});
  this.set('template', template);

  $.mockjax({
    url: `/api/admin/letter_templates/${template.get('id')}/preview`,
    status: 201,
    responseText: { letter_template: {body: 'dummy data present' } }
  });

  this.render(hbs`
    <div id="overlay-drop-zone"></div>
    {{admin-page/email-templates/preview template=template}}
  `);
  this.$("[data-test-selector='preview-email']").click();

  return wait().then(() => {
    assert.textPresent('.overlay-container', 'dummy data present');
  });
});
