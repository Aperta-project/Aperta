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

export default Ember.Route.extend({
  can: Ember.inject.service('can'),

  model(params) {
    if (this.store.peekAll('admin-journal').get('length')) {
      return {
        journals: this.store.peekAll('admin-journal'),
        journal: this.store.peekRecord('admin-journal', params.journal_id)
      };
    } else {
      return this.store.findAll('admin-journal').then((journals) => {
        return {
          journals: journals,
          journal: journals.find(j => j.id === params.journal_id)
        };
      });
    }
  },

  afterModel(model, transition) {
    if (this._transitionRoutable(model, transition)) { return; }

    if (this._needsRedirection(model)) {
      const journal = this._determineSubject(model, transition);

      return this.get('can').can('administer', journal).then( (value)=> {
        if (model.journal && value) { return; }

        const route = 'admin.journals.' + (value ? 'workflows' : 'users');
        if (!transition || !(transition.targetName === route) || this._invalidAllTransition(model, transition)) {
          return this.transitionTo(route, journal.id);
        }
      });
    }
  },

  _transitionRoutable(model, transition) {
    if (!transition || this._invalidAllTransition(model, transition)) { return false; }

    return this.get('_manageUsersRoutes').some((name) => {
      return transition.targetName.match(name);
    });
  },

  _determineSubject(model) {
    if (model.journal) {
      return model.journal;
    }
    else {
      return model.journals.get('firstObject');
    }
  },

  _needsRedirection(model) {
    return (!model.journal && model.journals.get('length') === 1) ||
      model.journal;
  },

  _invalidAllTransition(model, transition) {
    // avoids going to `journals/all` routes with only one journal
    return transition.params['admin.journals'].journal_id === 'all' &&
      model.journals.get('length') === 1;
  },

  _manageUsersRoutes: [/users$/,  /mailtemplates$/]
});
