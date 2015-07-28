import Ember from 'ember';
import FileUploadMixin from 'tahi/mixins/file-upload';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';
import RESTless from 'tahi/services/rest-less';

export default Ember.Controller.extend(FileUploadMixin, ValidationErrorsMixin, {
  showAffiliationForm: false,
  errorText: '',
  affiliations: Ember.computed.alias('model.affiliationsByDate'),

  selectableInstitutions: Ember.computed('model.institutions', function() {
    return this.get('model.institutions').map(function(institution) {
      return {
        id: institution,
        text: institution
      };
    });
  }),

  countries: [],
  _getCountries: Ember.on('init', function() {
    RESTless.get('/api/countries').then((data)=> {
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

      affiliation.save().then((a) => {
        this.send('hideNewAffiliationForm');
        // TODO: Remove when Ember-Data handles relationships
        a.get('user.affiliations').addObject(a);
      }, (response) => {
        affiliation.set('user', null);
        this.displayValidationErrorsFromResponse(response);
      });
    }
  }
});
