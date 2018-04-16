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

import { test, moduleFor } from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';
moduleFor('model:export-delivery', 'Unit | Model | export-delivery', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
  }
});

// test for boolean flags based on delivery state
var state_expectations = [
  {state: 'pending', failed: false, succeeded: false, incomplete: true, humanReadableState: 'is pending'},
  {state: 'in_progress', failed: false, succeeded: false, incomplete: true, humanReadableState: 'is in progress'},
  {state: 'delivered', failed: false, succeeded: true, incomplete: false, humanReadableState: 'succeeded'},
  {state: 'preprint_posted', failed: false, succeeded: true, incomplete: false, humanReadableState: 'succeeded'},
  {state: 'failed', failed: true, succeeded: false, incomplete: false, humanReadableState: 'has failed'},
];

state_expectations.forEach((state_expectation)=>{
  test(`state flags consistent when state is ${state_expectation.state}`, (assert)=>{
    var export_delivery = make('export-delivery', { state: state_expectation.state });
    assert.equal(export_delivery.get('succeeded'), state_expectation.succeeded, 'succeeded flag is correct');
    assert.equal(export_delivery.get('incomplete'), state_expectation.incomplete, 'incomplete flag is correct');
    assert.equal(export_delivery.get('preprint_posted'), state_expectation.posted, 'posted flag is correct');
    assert.equal(export_delivery.get('failed'), state_expectation.failed, 'failed flag is correct');
    assert.equal(export_delivery.get('humanReadableState'), state_expectation.humanReadableState,
      'human-readable state is correct');
  });
});

// test for reported export DOI pre/post preprint DOI assignment

var expectations_pre = [
  {destination: 'apex', preprintDoiAssigned: false, exportDoi: 'pone.1234567'},
  {destination: 'preprint', preprintDoiAssigned: false, exportDoi: null},
  {destination: 'em', preprintDoiAssigned: false, exportDoi: 'pone.1234567'},
];

expectations_pre.forEach((doi_expectation)=>{
  test(`export DOI with destination of "${doi_expectation.destination}" prior to preprint DOI assignment`, (assert)=>{
    var paper_pre = make('paper', { doi: 'pone.1234567' });
    var export_delivery_pre = make('export-delivery', {
      destination: doi_expectation.destination,
      paper: paper_pre
    });

    assert.equal(export_delivery_pre.get('preprintDoiAssigned'), doi_expectation.preprintDoiAssigned,
      'preprintDoiAssigned flag is correct');
    assert.equal(export_delivery_pre.get('exportDoi'), doi_expectation.exportDoi, 'exportDoi is correct');
  });
});

var expectations_post = [
  {destination: 'apex', preprintDoiAssigned: false, exportDoi: 'pone.1234567'},
  {destination: 'preprint', preprintDoiAssigned: true, exportDoi: 'aarx.1234567'},
  {destination: 'em', preprintDoiAssigned: false, exportDoi: 'pone.1234567'},
];

expectations_post.forEach((doi_expectation)=>{
  test(`export DOI with destination of "${doi_expectation.destination}" after preprint DOI assignment`, (assert)=>{
    var paper_post = make('paper', { doi: 'pone.1234567', aarxDoi: 'aarx.1234567' });
    var export_delivery_post = make('export-delivery', {
      destination: doi_expectation.destination,
      paper: paper_post
    });

    assert.equal(export_delivery_post.get('preprintDoiAssigned'), doi_expectation.preprintDoiAssigned,
      'preprintDoiAssigned flag is correct');
    assert.equal(export_delivery_post.get('exportDoi'), doi_expectation.exportDoi, 'exportDoi is correct');
  });
});
