import Ember from 'ember';

const { computed } = Ember;

export default Ember.Component.extend({
  classNames: ['add-author-form'],
  author: null,

  authorContributionIdents: [
    'author--contributions--conceived_and_designed_experiments',
    'author--contributions--performed_the_experiments',
    'author--contributions--analyzed_data',
    'author--contributions--contributed_tools',
    'author--contributions--contributed_writing'
  ],

  isOtherContributionSelected: computed('author.nestedQuestions', function(){
    const answer = this.get('author')
                       .answerForQuestion('author--contributions--other');

    if(answer){
      return answer.get('value');
    }

    return false;
  }),

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

    toggleOtherContribution(checkbox){
      if(!checkbox.get('checked')){
        const answer = this.get('author')
                           .answerForQuestion('author--contributions--other');
        answer.destroyRecord();
      }
    },

    validateField(key, value) {
      if(this.attrs.validateField) {
        this.attrs.validateField(key, value);
      }
    }
  }
});
