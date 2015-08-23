import Ember from 'ember';
import FileUploadMixin from 'tahi/mixins/file-upload';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Controller.extend(FileUploadMixin, ValidationErrorsMixin, {
  restless: Ember.inject.service('restless'),

  showAffiliationForm: false,
  errorText: '',
  affiliations: Ember.computed.alias('model.affiliationsByDate'),

  countries: [],
  _getCountries: Ember.on('init', function() {
    this.get('restless').get('/api/countries').then((data)=> {
      if(Ember.isEmpty(data.countries)) { return; }
      this.set('countries', data.countries.map(function(c) {
        return { id: c, text: c };
      }));
    });
  }),

  actions: {
    resetPassword() {
      $.get('/api/users/reset').always(() => {
        this.set('resetPasswordSuccess', true);
      });
    },

    hideNewAffiliationForm() {
      this.clearAllValidationErrors();
      this.set('showAffiliationForm', false);
      if (this.get('newAffiliation.isNew')) {
        this.get('newAffiliation').deleteRecord();
      }
    },

    showNewAffiliationForm() {
      this.set('newAffiliation', this.store.createRecord('affiliation'));
      this.set('showAffiliationForm', true);
    },

    removeAffiliation(affiliation) {
      if (confirm('Are you sure you want to destroy this affiliation?')) {
        affiliation.destroyRecord();
      }
    },

    commitAffiliation(affiliation) {
      affiliation.set('user', this.get('model'));
      this.clearAllValidationErrors();

      affiliation.save().then(() => {
        this.send('hideNewAffiliationForm');
      }, (response) => {
        affiliation.set('user', null);
        this.displayValidationErrorsFromResponse(response);
      });
    },

    institutionSelected(institution) {
      this.set('newAffiliation.name', institution.name);
      this.set('newAffiliation.ringgoldId', institution['institution-id']);
    }
  }
});
