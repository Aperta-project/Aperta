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

  affiliation: null,
  countries: null,
  editAffiliation: false,

  today: new Date(),

  select2Helper: function(item) {
    return { id: item, text: item };
  },

  formattedCountries: Ember.computed('countries.data.[]', function() {
    return this.get('countries.data').map(this.select2Helper);
  }),

  selectedCountry: Ember.computed('affiliation.country',function(){
    if (!this.get('affiliation.country')) { return null; }
    return this.select2Helper(this.get('affiliation.country'));
  }),

  institution: Ember.computed('affiliation.name', 'affiliation.ringgoldId', function() {
    if (!this.get('affiliation.name')){ return null; }

    return {
      name: this.get('affiliation.name'),
      'institution-id': this.get('affiliation.ringgoldId')
    };
  }),

  actions:{
    editAffiliation() {
      this.set('editAffiliation', true);
    },

    institutionSelected(institution) {
      this.set('affiliation.name', institution.name);
      this.set('affiliation.ringgoldId', institution['institution-id']);
    },

    countrySelected(country) {
      this.set('affiliation.country', country.text);
    },

    removeAffiliation(affiliation){
      this.sendAction('removeAffiliation', affiliation);
    },

    commitAffiliation(affiliation) {
      this.clearAllValidationErrors();
      this.get('commitAffiliation')(affiliation).then(() =>{
        this.set('editAffiliation', false);
      } , (response) => {
        affiliation.set('user', null);
        this.displayValidationErrorsFromResponse(response);
      });
    },

    hideNewAffiliationForm() {
      this.set('editAffiliation', false);
      this.get('affiliation').rollbackAttributes();
      this.clearAllValidationErrors();
      this.sendAction('hideNewAffiliationForm');
    }
  }
});
