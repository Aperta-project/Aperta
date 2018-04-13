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
import JournalAdminMixin from 'tahi/mixins/components/journal-administratable';

export default Ember.Component.extend(JournalAdminMixin, {
  classNames: ['admin-drawer-item'],

  initials: Ember.computed('journal.initials', function() {
    if (this.get('journal')) {
      return this.get('journal.initials');
    } else {
      return 'all';
    }
  }),

  title: Ember.computed('journal.name', function() {
    if (this.get('journal')) {
      return this.get('journal.name');
    } else {
      return 'All My Journals';
    }
  }),

  linkId: Ember.computed('journal', function() {
    if (this.get('journal')) {
      return this.get('journal.id');
    } else {
      return 'all';
    }
  }),

  // the `canAdminJournal` property can be found in the mixin referenced at the top
  linkValue: Ember.computed('canAdminJournal', function() {
    const linkBase = 'admin.journals.';

    if(this.get('canAdminJournal')) {
      return linkBase + 'workflows';
    } else {
      return linkBase + 'users';
    }
  }),
});
