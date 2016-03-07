import Ember from 'ember';
import { contributionIdents } from 'tahi/authors-task-validations';

const {
  Component,
  computed,
  inject: { service }
} = Ember;

export default Component.extend({
  countries: service(),
  classNames: ['add-author-form'],
  author: null,

  init() {
    this._super(...arguments);
    this.get('countries').fetch();
  },

  formattedCountries: computed('countries.data', function() {
    return this.get('countries.data').map(function(c) {
      return { id: c, text: c };
    });
  }),

  authorContributionIdents: contributionIdents,

  affiliation: computed('author', function() {
    if (this.get('author.affiliation')) {
      return {
        id: this.get('author.ringgoldId'),
        name: this.get('author.affiliation')
      };
    }
  }),

  secondaryAffiliation: computed('author', function() {
    if (this.get('author.secondaryAffiliation')) {
      return {
        id: this.get('author.secondaryRinggoldId'),
        name: this.get('author.secondaryAffiliation')
      };
    }
  }),

  selectedCurrentAddressCountry: computed('author.currentAddressCountry', function() {
    return this.get('formattedCountries').findBy(
      'text',
      this.get('author.currentAddressCountry')
    );
  }),

  resetAuthor() {
    this.get('author').rollback();
  },

  actions: {
    cancelEdit() {
      this.resetAuthor();
      this.sendAction('hideAuthorForm');
    },

    saveNewAuthor() {
      this.sendAction('saveAuthor', this.get('author'));
    },

    addContribution(name) {
      this.get('author.contributions').addObject(name);
    },

    removeContribution(name) {
      this.get('author.contributions').removeObject(name);
    },

    resolveContributions(newContributions, unmatchedContributions) {
      this.get('author.contributions').removeObjects(unmatchedContributions);
      this.get('author.contributions').addObjects(newContributions);
    },

    institutionSelected(institution) {
      this.set('author.affiliation', institution.name);
      this.set('author.ringgoldId', institution['institution-id']);
    },

    unknownInstitutionSelected(institutionName) {
      this.set('author.affiliation', institutionName);
      this.set('author.ringgoldId', '');
    },

    secondaryInstitutionSelected(institution) {
      this.set('author.secondaryAffiliation', institution.name);
      this.set('author.secondaryRinggoldId', institution['institution-id']);
    },

    unknownSecondaryInstitutionSelected(institutionName) {
      this.set('author.secondaryAffiliation', institutionName);
      this.set('author.secondaryRinggoldId', '');
    },

    currentAddressCountrySelected(data) {
      this.set('author.currentAddressCountry', data.text);
    },

    validateField(key, value) {
      if(this.attrs.validateField) {
        this.attrs.validateField(key, value);
      }
    }
  }
});
