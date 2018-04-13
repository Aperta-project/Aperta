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

import hbs from 'htmlbars-inline-precompile';
import sinon from 'sinon';
import { manualSetup, make } from 'ember-data-factory-guy';
import { moduleForComponent, test } from 'ember-qunit';

moduleForComponent('reviewer-report-status', 'Integration | Component | reviewer report status', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    this.set('reviewerReport', make('reviewer-report'));
    this.set('canEditDueDate', true);
  }
});

let template = hbs`{{reviewer-report-status
                      report=reviewerReport
                      canEditDueDate=canEditDueDate
                      uiState='closed'}}`;

test('should save due-datetime on date selection', function(assert){
  let spy = sinon.spy();
  let dueDatetime = make('due-datetime', { save: spy });
  this.set('reviewerReport.dueDatetime', dueDatetime);
  this.render(template);

  this.$('.date-picker-link').click();
  this.$('.datepicker').datepicker('setDate', '10/12/2020');

  assert.equal(spy.called, true, 'dueDatetime.save called');
});
