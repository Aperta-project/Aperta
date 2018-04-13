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
import sinon from 'sinon';
import * as AdminCardPermission from 'tahi/lib/admin-card-permission';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent('card-editor/permissions/role', 'Integration | Component | card editor | permissions | role', {
  integration: true
});

test('it renders participant checkboxes', function(assert) {
  sinon.stub(AdminCardPermission, 'permissionExists');
  const card = Ember.Object.create({ id: 1 });
  const role = Ember.Object.create({name: 'Foo'});
  this.setProperties({card: card, role: role, noop: sinon.stub()});

  this.render(hbs `{{card-editor/permissions/role
                    role=role
                    card=card
                    turnOnPermission=noop
                    turnOffPermission=noop}}`);

  assert.elementFound('input[name=Foo-manage_participant]');
  assert.elementFound('input[name=Foo-view_participants]');
});
