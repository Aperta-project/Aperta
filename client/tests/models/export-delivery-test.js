import Ember from 'ember';
import { test, moduleForModel } from 'ember-qunit';
import startApp from 'tahi/tests/helpers/start-app';
import FactoryGuy from 'ember-data-factory-guy';
import * as TestHelper from 'ember-data-factory-guy';

var App;

moduleForModel('export-delivery', 'Unit | Model | export-delivery', {
  needs: ['model:paper', 'model:export-delivery'],
  afterEach: function() {
    Ember.run(function() {
      return TestHelper.teardown();
    });
    return Ember.run(App, 'destroy');
  },
  beforeEach: function() {
    App = startApp();
    return TestHelper.setup(App);
  }
});

// test for boolean flags based on delivery state
var state_expectations = [
  {state: 'pending', failed: false, succeeded: false, incomplete: true, humanReadableState: 'is pending'},
  {state: 'in_progress', failed: false, succeeded: false, incomplete: true, humanReadableState: 'is in progress'},
  {state: 'delivered', failed: false, succeeded: true, incomplete: false, humanReadableState: 'succeeded'},
  {state: 'failed', failed: true, succeeded: false, incomplete: false, humanReadableState: 'has failed'},
];

state_expectations.forEach((state_expectation)=>{
  test(`state flags consistent when state is ${state_expectation.state}`, (assert)=>{
    var export_delivery = FactoryGuy.make('export-delivery', { state: state_expectation.state });
    assert.equal(export_delivery.get('succeeded'), state_expectation.succeeded, 'succeeded flag is correct');
    assert.equal(export_delivery.get('incomplete'), state_expectation.incomplete, 'incomplete flag is correct');
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
    var paper_pre = FactoryGuy.make('paper', { doi: 'pone.1234567' });
    var export_delivery_pre = FactoryGuy.make('export-delivery', {
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
    var paper_post = FactoryGuy.make('paper', { doi: 'pone.1234567', aarxDoi: 'aarx.1234567' });
    var export_delivery_post = FactoryGuy.make('export-delivery', {
      destination: doi_expectation.destination,
      paper: paper_post
    });

    assert.equal(export_delivery_post.get('preprintDoiAssigned'), doi_expectation.preprintDoiAssigned,
      'preprintDoiAssigned flag is correct');
    assert.equal(export_delivery_post.get('exportDoi'), doi_expectation.exportDoi, 'exportDoi is correct');
  });
});
