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

import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  // permissionModelName is used by the can service to
  // clarify that the adminJournal is really a journal, as far as
  // permissions are concerned.
  permissionModelName: 'journal',

  manuscriptManagerTemplates: DS.hasMany('manuscript-manager-template'),
  journalTaskTypes: DS.hasMany('journal-task-type', {async: false}),
  adminJournalRoles: DS.hasMany('admin-journal-role', {async: false}),
  adminJournalLevelRoles: Ember.computed.filterBy('adminJournalRoles', 'assignedToTypeHint', 'Journal'),
  createdAt: DS.attr('date'),
  description: DS.attr('string'),
  logoUrl: DS.attr('string'),
  manuscriptCss: DS.attr('string'),
  name: DS.attr('string'),
  paperCount: DS.attr('number'),
  paperTypes: DS.attr(),
  pdfCss: DS.attr('string'),
  mswordAllowed: DS.attr('boolean'),
  lastDoiIssued: DS.attr('string'),
  doiJournalPrefix: DS.attr('string'),
  doiPublisherPrefix: DS.attr('string'),
  letterTemplateScenarios: DS.attr(),

  // Card config:

  cards: DS.hasMany('card'),
  cardTaskTypes: DS.hasMany('card-task-type'),
  initials: Ember.computed('name', function() {
    return this.get('name').split(' ').map(s => s[0]).join('');
  })
});
