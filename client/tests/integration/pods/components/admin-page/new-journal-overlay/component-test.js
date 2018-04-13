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
import sinon from 'sinon';
import { instaPromise } from 'tahi/tests/helpers/promise-helpers';

moduleForComponent('admin-page/new-journal-overlay', 'Integration | Component | Admin page | new journal overlay', {
  integration: true
});


function mockStore(record) {
  return {
    createRecord() {
      return record;
    }
  };
}

function mockRouting() {
  return {
    transitionTo() {
      return true;
    }
  };
}

test('it creates a record when the save button is pushed', function(assert) {
  const mockRecord = {
    save() {
      return instaPromise(true, { id: 72 });
    }
  };
  sinon.stub(mockRecord, 'save', mockRecord.save);

  this.set('store', mockStore(mockRecord));
  this.set('routing', mockRouting());
  const success = sinon.spy();
  this.on('success', success);
  const close = sinon.spy();
  this.on('close', close);

  this.render(hbs`{{admin-page/new-journal-overlay
    store=store
    routing=routing
    success=(action "success")
    close=(action "close")}}`);

  this.$('.admin-new-journal-overlay-save').click();
  assert.spyCalled(mockRecord.save, 'should save a new record');
  assert.spyCalled(success, 'Should call success callback');
  assert.spyCalled(close, 'Should call close');
});


test('it does not create a record when the cancel button is pushed', function(assert) {
  const mockRecord = {
    save() {
      return instaPromise(true, { id: 37 });
    }
  };
  sinon.stub(mockRecord, 'save', mockRecord.save);

  this.set('store', mockStore(mockRecord));
  this.set('routing', mockRouting());
  const success = sinon.spy();
  this.on('success', success);
  const close = sinon.spy();
  this.on('close', close);

  this.render(hbs`{{admin-page/new-journal-overlay
    store=store
    routing=routing
    success=(action "success")
    close=(action "close")}}`);

  this.$('.admin-new-journal-overlay-cancel').click();

  assert.spyNotCalled(mockRecord.save, 'should not create a new record');
  assert.spyNotCalled(success, 'Should not call success callback');
  assert.spyCalled(close, 'Should call close');
});
