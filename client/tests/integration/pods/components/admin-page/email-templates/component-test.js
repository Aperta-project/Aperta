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
import FakeCanService from 'tahi/tests/helpers/fake-can-service';

moduleForComponent('admin-page/email-templates',
  'Integration | Component | Admin Page | Email Templates', {
    integration: true,

    beforeEach() {
      this.can = FakeCanService.create();
      this.register('service:can', this.can.asService());
    }
  }
);

const template = {
  name: 'TPS reports',
  subject: 'Yeaahhhh....'
};

const templates = [template, template];


test('it renders tr in the tbody for each template', function(assert) {
  this.set('templates', templates);
  this.set('journal', {id: 1});

  this.render(hbs`
    {{admin-page/email-templates templates=templates journal=journal}}
  `);

  assert.nElementsFound('.admin-email-template-row', templates.length);
});

test('it does not render a table if there is no journal', function(assert) {
  this.set('templates', templates);
  this.set('journal', null);

  this.render(hbs`
    {{admin-page/email-templates templates=templates journal=journal}}
  `);

  assert.nElementsFound('.admin-email-template-row', 0);
});
