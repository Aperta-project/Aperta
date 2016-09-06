import Ember from 'ember';
import { contributionIdents } from 'tahi/models/author';
import ObjectProxyWithErrors from 'tahi/models/object-proxy-with-validation-errors';

const {
  Component,
  computed,
  computed: { alias },
  inject: { service }
} = Ember;

export default Component.extend({
  countries: service(),
  store: service(),

  classNames: ['author-form', 'individual-author-form'],

  author: null,
  authorProxy: null,
  isNewAuthor: false,
  validationErrors: alias('authorProxy.validationErrors'),

  init() {
    this._super(...arguments);
    this.get('countries').fetch();

    if(this.get('isNewAuthor')) {
      this.initNewAuthorQuestions().then(() => {
        this.createNewAuthor();
      });
    }
  },

  nestedQuestionsForNewAuthor: Ember.A(),
  initNewAuthorQuestions(){
    const q = { type: 'Author' };
    return this.get('store').query('nested-question', q).then(
      (nestedQuestions) => {
        this.set('nestedQuestionsForNewAuthor', nestedQuestions.toArray());
      });
  },

  clearNewAuthorAnswers(){
    this.get('nestedQuestionsForNewAuthor').forEach( (nestedQuestion) => {
      nestedQuestion.clearAnswerForOwner(this.get('newAuthor.object'));
    });
  },

  createNewAuthor() {
    const newAuthor = this.get('store').createRecord('author', {
      paper: this.get('task.paper'),
      position: 0,
      nestedQuestions: this.get('nestedQuestionsForNewAuthor')
    });

    this.set('author', newAuthor);

    this.set('authorProxy', ObjectProxyWithErrors.create({
      object: newAuthor,
      validations: newAuthor.validations
    }));
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
    this.get('author').rollbackAttributes();
  },

  saveAuthor() {
    this.get('authorProxy').validateAll();
    if(this.get('authorProxy.errorsPresent')) { return; }
    this.get('author').save().then(() => {
      this.attrs.saveSuccess();
    });
  },

  saveNewAuthor() {
    const author = this.get('author');
    author.save().then(savedAuthor => {
      author.get('nestedQuestionAnswers').toArray().forEach(function(answer){
        const value = answer.get('value');
        if(value || value === false){
          answer.set('owner', savedAuthor);
          answer.save();
        }
      });

      this.attrs.saveSuccess();
    });
  },

  actions: {
    cancelEdit() {
      this.resetAuthor();
      this.sendAction('hideAuthorForm');
    },

    saveAuthor() {
      if(this.get('isNewAuthor')) {
        this.saveNewAuthor();
      } else {
        this.saveAuthor();
      }
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
