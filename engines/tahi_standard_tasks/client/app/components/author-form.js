import Ember from 'ember';
import { contributionIdents } from 'tahi/models/author';
import CommonAuthorForm from 'tahi/mixins/components/common-author-form';

const {
  Component,
  computed,
  inject: { service },
  isEqual
} = Ember;

export default Component.extend(CommonAuthorForm, {
  countries: service(),
  store: service(),

  classNames: ['author-form', 'individual-author-form'],

  isNewAuthor: false,
  canRemoveOrcid: null,

  init() {
    this._super(...arguments);
    this.get('countries').fetch();
  },

  authorIsNotCurrentUser: computed('currentUser', 'author.user', function() {
    const currentUser = this.get('currentUser');
    // For more information on how this works at all look up the docs for the
    // DS.PromiseObject
    const author = this.get('author.user.content'); // <- promise
    return !isEqual(currentUser, author);
  }),

  authorIsPaperCreator: computed('author.user', 'author.paper.creator', function() {
    const author = this.get('author.user.content');
    const creator = this.get('author.paper.creator');
    return isEqual(author, creator);
  }),

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

  validateOrcid: Ember.observer('author.orcidAccount.identifier', function() {
    const ident = this.get('author.orcidAccount.identifier');
    if(ident) {
      this.send('validateField', 'orcidIdentifier', ident);
    }
  }),

  actions: {
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
    }
  }
});
