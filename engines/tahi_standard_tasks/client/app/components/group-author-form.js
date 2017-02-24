import Ember from 'ember';
import { contributionIdents } from 'tahi/models/group-author';
import ObjectProxyWithErrors from 'tahi/models/object-proxy-with-validation-errors';

export default Ember.Component.extend({
  classNames: ['author-form', 'group-author-form'],
  author: null,
  authorProxy: null,
  validationErrors: Ember.computed.alias('authorProxy.validationErrors'),
  store: Ember.inject.service(),
  can: Ember.inject.service(),

  authorshipConfirmed: Ember.computed.alias('author.confirmedAsCoAuthor'),
  authorshipDeclined: Ember.computed.alias('author.refutedAsCoAuthor'),

  init() {
    this._super(...arguments);

    if(this.get('isNewAuthor')) {
      this.initNewAuthorQuestions().then(() => {
        this.createNewAuthor();
        this.initializeCoauthorshipControls();
      });
    } else {
      this.initializeCoauthorshipControls();
    }
  },

  humanizedCoAuthorState: Ember.computed('author.coAuthorState', function(){
    switch(this.get('author.coAuthorState')) {
      case "confirmed":
        return "Confirmed by";
      case "refuted":
        return "Refuted By";
      default:
        return "Last changed by";
    }
  }),

  initializeCoauthorshipControls() {
    this.get('author.paper.journal').then( (journal) => {
      this.get('can').can('administer', journal).then( (value) => {
        Ember.run( () => {
          this.set('canChangeCoauthorStatus', value);
        });
      });
    });
  },

  nestedQuestionsForNewAuthor: Ember.A(),
  initNewAuthorQuestions(){
    const q = { type: 'GroupAuthor' };
    return this.get('store').query('nested-question', q).then((nestedQuestions)=> {
      this.set('nestedQuestionsForNewAuthor', nestedQuestions);
    });
  },

  clearNewAuthorAnswers(){
    this.get('nestedQuestionsForNewAuthor').forEach( (nestedQuestion) => {
      nestedQuestion.clearAnswerForOwner(this.get('newAuthor.object'));
    });
  },

  createNewAuthor() {
    const newAuthor = this.get('store').createRecord('group-author', {
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

  authorContributionIdents: contributionIdents,

  saveAuthor() {
    this.get('authorProxy').validateAll();
    if(this.get('authorProxy.errorsPresent')) { return; }
    this.get('author').save();
    this.attrs.saveSuccess();
  },

  saveNewAuthor() {
    const author = this.get('author'); ``
    author.save().then(savedAuthor => {
      author.get('nestedQuestionAnswers').toArray().forEach(function(answer){
        const value = answer.get('value');
        if(value || value === false){
          answer.set('owner', savedAuthor);
          answer.save();
        }
      });
    });

    this.attrs.saveSuccess();
  },

  resetAuthor() {
    this.get('author').rollbackAttributes();
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

    selectAuthorConfirmation(status) {
      this.set('author.coAuthorState', status);
    },

    validateField(key, value) {
      if(this.attrs.validateField) {
        this.attrs.validateField(key, value);
      }
    }
  }
});
