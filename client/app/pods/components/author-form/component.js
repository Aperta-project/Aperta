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
import { contributionIdents } from 'tahi/pods/author/model';
import ObjectProxyWithErrors from 'tahi/pods/object-proxy-with-validation-errors/model';

const {
  Component,
  computed,
  computed: { alias },
  inject: { service },
  isEqual
} = Ember;

export default Component.extend({
  countries: service(),
  store: service(),
  can: service(),

  classNames: ['author-form', 'individual-author-form'],

  author: null,
  authorProxy: null,
  isNewAuthor: false,
  validationErrors: alias('authorProxy.validationErrors'),
  canRemoveOrcid: null,
  canChangeCoauthorStatus: null,

  authorshipConfirmed: Ember.computed.alias('author.confirmedAsCoAuthor'),
  authorshipDeclined: Ember.computed.alias('author.refutedAsCoAuthor'),

  init() {
    this._super(...arguments);
    let countries = this.get('countries');
    countries.get('fetch').perform();

    if(this.get('isNewAuthor')) {
      this.initNewAuthorQuestions().then(() => {
        this.createNewAuthor();
        this.initializeCoauthorshipControls();
      });
    } else {
      this.initializeCoauthorshipControls();
    }
  },

  initializeCoauthorshipControls() {
    const paper = this.get('author.paper');

    this.get('can').can('manage_paper_authors', paper).then( (value) => {
      Ember.run( () => {
        this.set('canChangeCoauthorStatus', value);
      });
    });
  },

  authorIsNotCurrentUser: computed('currentUser', 'author.user', function() {
    const currentUser = this.get('currentUser');
    const author = this.get('author.user.content'); // <- promise
    return !isEqual(currentUser, author);
  }),

  authorIsPaperCreator: computed('author.user', 'author.paper.creator', function() {
    const author = this.get('author.user.content');
    const creator = this.get('author.paper.creator');
    return isEqual(author, creator);
  }),

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
    this.get('author').save()
    .then(() => {
      this.get('saveSuccess')();
    })
    .catch(response => {
      let authorProxy = this.get('authorProxy');
      authorProxy.displayValidationErrorsFromResponse(response);
    });
  },

  saveNewAuthor() {
    const author = this.get('author');
    author.save()
    .then(savedAuthor => {
      author.get('nestedQuestionAnswers').toArray().forEach(function(answer) {
        const value = answer.get('value');
        if (value || value === false) {
          answer.set('owner', savedAuthor);
          answer.save();
        }
      });
      this.get('saveSuccess')();
    })
    .catch(response => {
      let authorProxy = this.get('authorProxy');
      authorProxy.displayValidationErrorsFromResponse(response);
    });
  },

  validateOrcid: Ember.observer('author.orcidAccount.identifier', function() {
    const ident = this.get('author.orcidAccount.identifier');
    if(ident) {
      this.send('validateField', 'orcidIdentifier', ident);
    }
  }),

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

    selectAuthorConfirmation(status) {
      this.set('author.coAuthorState', status);
    },

    validateField(key, value) {
      if(this.get('validateField')) {
        this.get('validateField')(key, value);
      }
    }
  }
});
