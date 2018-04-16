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
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin,{

  //pass this in
  user: null,

  restless: Ember.inject.service(),
  store: Ember.inject.service(),
  countries: Ember.inject.service(),

  showAffiliationForm: false,
  affiliations: Ember.computed(function() { return []; }),
  loading: true,

  newAffiliation: null,

  init() {
    this._super(...arguments);
    let countries = this.get('countries');
    countries.get('fetch').perform();
  },

  didInsertElement() {
    this._super(...arguments);
    const store = this.get('store');
    const userId = this.get('user.id');

    this.get('restless')
    .get(`/api/affiliations/user/${userId}`)
    .then((data) => {
      store.pushPayload(data);
      this.set(
        'affiliations',
        store.peekAll('affiliation').filterBy('user.id', userId)
      );
      this.set('loading', false);
    });
  },

  actions: {
    hideNewAffiliationForm() {
      this.clearAllValidationErrors();
      this.set('showAffiliationForm', false);
      if (this.get('newAffiliation.isNew')) {
        this.get('newAffiliation').deleteRecord();
      }
    },

    showNewAffiliationForm() {
      this.set('newAffiliation', this.get('store').createRecord('affiliation'));
      this.set('showAffiliationForm', true);
    },

    removeAffiliation(affiliation) {
      if (window.confirm('Are you sure you want to destroy this affiliation?')) {
        this.get('affiliations').removeObject(affiliation);
        affiliation.destroyRecord();
      }
    },

    commitAffiliation(affiliation) {
      return this.get('store').findRecord('user', this.get('user.id')).then((user)=>{
        user.get('affiliations').addObject(affiliation);
        this.clearAllValidationErrors();
        const isNew = affiliation.get('isNew');
        return affiliation.save().then(() => {
          this.send('hideNewAffiliationForm');
          if (isNew) { this.get('affiliations').pushObject(affiliation); }
        });
      });
    },

    institutionSelected(institution) {
      this.set('newAffiliation.name', institution.name);
      this.set('newAffiliation.ringgoldId', institution['institution-id']);
    },

    countrySelected(country) {
      this.set('newAffiliation.country', country.text);
    },
  }
});
