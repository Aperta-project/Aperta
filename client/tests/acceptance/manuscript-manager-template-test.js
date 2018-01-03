// Generated by CoffeeScript 1.10.0
import Ember from 'ember';
import { test } from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import * as TestHelper from 'ember-data-factory-guy';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';

moduleForAcceptance('Integration: Manuscript Manager Templates', {
  beforeEach: function() {
    return Ember.run(() => {
      $.mockjax({
        url: '/api/admin/journals/authorization',
        status: 204
      });

      $.mockjax({
        type: 'GET',
        url: '/api/journals',
        status: 200,
        responseText: {
          journals: []
        }
      });
    });
  }
});

test('Changing phase name', function(assert) {
  var adminJournal, columnTitleSelect, mmt;
  adminJournal = FactoryGuy.make('admin-journal', {
    id: 1
  });
  mmt = FactoryGuy.make('manuscript-manager-template', {
    id: 1,
    journal: adminJournal
  });
  FactoryGuy.make('phase-template', {
    id: 1,
    manuscriptManagerTemplate: mmt,
    name: 'Phase 1'
  });
  TestHelper.mockFindRecord('admin-journal').returns({
    model: adminJournal
  });

  columnTitleSelect = 'h2.column-title:contains("Phase 1")';

  visit('/admin/mmt/journals/1/manuscript_manager_templates/1/edit');

  click(columnTitleSelect).then(function() {
    return Ember.$(columnTitleSelect).html('Shazam!');
  });
  andThen(function() {
    assert.textPresent('h2.column-title', 'Shazam!');
  });
});

test('Adding an Ad-Hoc card', function(assert) {
  var adminJournal, journalTaskType, mmt, pt;
  journalTaskType = FactoryGuy.make('journal-task-type', {
    id: 1,
    kind: "AdHocTask",
    title: "Ad Hoc"
  });
  adminJournal = FactoryGuy.make('admin-journal', {
    id: 1,
    journalTaskTypes: [journalTaskType]
  });
  mmt = FactoryGuy.make('manuscript-manager-template', {
    id: 1,
    journal: adminJournal
  });
  pt = FactoryGuy.make('phase-template', {
    id: 1,
    manuscriptManagerTemplate: mmt,
    name: "Phase 1"
  });
  TestHelper.mockFindRecord('admin-journal').returns({
    model: adminJournal
  });
  visit('/admin/mmt/journals/1/manuscript_manager_templates/1/edit');
  click('.button--green:contains("Add New Card")');
  click('label:contains("Ad Hoc")');
  click('.overlay .button--green:contains("Add")');
  andThen(function() {
    assert.elementFound('h1.inline-edit:contains("Ad Hoc")');
    assert.notOk(find('h1.inline-edit').hasClass('editing'), 'The title should not be editable to start');
  });

  click('.adhoc-content-toolbar .fa-plus');
  click('.adhoc-content-toolbar .adhoc-toolbar-item--label');
  fillInContentEditable('.inline-edit-form div[contenteditable]', 'New contenteditable, yahoo!');
  click('.task-body .inline-edit-body-part .button--green:contains("Save")');
  andThen(function() {
    return assert.textPresent('.inline-edit', 'yahoo', 'text is still correct');
  });
  click('.inline-edit-body-part .fa-trash');
  andThen(function() {
    return assert.textPresent('.inline-edit-body-part', 'Are you sure?');
  });
  click('.inline-edit-body-part .delete-button');
  andThen(function() {
    return assert.textNotPresent('.inline-edit', 'yahoo', 'Deleted text is gone');
  });
  click('.overlay-close-button');
  click('.card-title');
  return andThen(function() {
    return assert.elementFound('h1.inline-edit:contains("Ad Hoc")', 'User can edit the existing ad-hoc card');
  });
});

test('User cannot edit a non Ad-Hoc card', function(assert) {
  var adminJournal, journalTaskType, mmt, pt;
  journalTaskType = FactoryGuy.make('journal-task-type', {
    id: 1,
    kind: "BillingTask",
    title: "Billing"
  });
  adminJournal = FactoryGuy.make('admin-journal', {
    id: 1,
    journalTaskTypes: [journalTaskType]
  });
  mmt = FactoryGuy.make('manuscript-manager-template', {
    id: 1,
    journal: adminJournal
  });
  pt = FactoryGuy.make('phase-template', {
    id: 1,
    manuscriptManagerTemplate: mmt,
    name: "Phase 1"
  });
  TestHelper.mockFindRecord('admin-journal').returns({
    model: adminJournal
  });
  visit('/admin/mmt/journals/1/manuscript_manager_templates/1/edit');
  click('.button--green:contains("Add New Card")');
  click('label:contains("Billing")');
  click('.overlay .button--green:contains("Add")');
  click('.card-title');
  return andThen(function() {
    return assert.elementNotFound('.ad-hoc-template-overlay', 'Clicking any other card has no effect');
  });
});

test('User can enable a workflow as preprint eligible', function(assert){
  var adminJournal, journalTaskType, mmt;

  FactoryGuy.make('feature-flag', {id: 1, name: 'PREPRINT', active: true});
  journalTaskType = FactoryGuy.make('journal-task-type', {
    id: 1,
    kind: 'AdHocTask',
    title: 'Ad Hoc'
  });
  adminJournal = FactoryGuy.make('admin-journal', {
    id: 1,
    journalTaskTypes: [journalTaskType]
  });
  mmt = FactoryGuy.make('manuscript-manager-template', {
    id: 1,
    journal: adminJournal
  });
  FactoryGuy.make('phase-template', {
    id: 1,
    manuscriptManagerTemplate: mmt,
    name: 'Phase 1'
  });
  TestHelper.mockFindRecord('admin-journal').returns({
    model: adminJournal
  });

  $.mockjax({
    url: '/api/manuscript_manager_templates/1',
    status: 204
  });

  visit('/admin/mmt/journals/1/manuscript_manager_templates/1/edit');
  andThen(() => {
    assert.elementFound('.preprint-eligible');
  });

  click('.preprint-eligible input');
  andThen(() => {
    assert.mockjaxRequestMade('/api/manuscript_manager_templates/1', 'PUT', 'request made after click');
  });
});

test('Preprint eligible is hidden if feature flag is not set', function(assert){
  var adminJournal, journalTaskType, mmt;
  journalTaskType = FactoryGuy.make('journal-task-type', {
    id: 1,
    kind: 'AdHocTask',
    title: 'Ad Hoc'
  });
  adminJournal = FactoryGuy.make('admin-journal', {
    id: 1,
    journalTaskTypes: [journalTaskType]
  });
  mmt = FactoryGuy.make('manuscript-manager-template', {
    id: 1,
    journal: adminJournal
  });
  FactoryGuy.make('phase-template', {
    id: 1,
    manuscriptManagerTemplate: mmt,
    name: 'Phase 1'
  });
  TestHelper.mockFindRecord('admin-journal').returns({
    model: adminJournal
  });

  $.mockjax({
    url: '/api/manuscript_manager_templates/1',
    status: 204
  });

  visit('/admin/mmt/journals/1/manuscript_manager_templates/1/edit');
  andThen(() => {
    assert.elementNotFound('.preprint-eligible');
  });
});
