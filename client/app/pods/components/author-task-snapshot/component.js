import Ember from 'ember';

const { computed } = Ember;
const { filterBy } = computed;

const findAuthors = function(authors) {
  return authors.filter((child) => {
    return child.name === 'author' ||
      child.name === 'group-author';
  });
};

const findChild = (author, key) => {
  return author.children.findBy('name', key).value;
};

const equivalentAuthor = (author, authors) => {
  return authors.find((item) => {
    return findChild(item,'id') === findChild(author, 'id') &&
      item.name === author.name;
  });
};

const positionSort = (a, b) => {
  let posA = findChild(a, 'position');
  let posB = findChild(b, 'position');
  if (posA < posB) {
    return -1;
  } else if (posA > posB) {
    return 1;
  } else {
    return 0;
  }

};

export default Ember.Component.extend({
  snapshot1: null, //Snapshots are passed in
  snapshot2: null,
  questions: Ember.A(),

  questionsViewing: filterBy('snapshot1.contents.children','type','question'),

  questionsComparing: filterBy('snapshot2.contents.children','type','question'),

  setQuestions: function() {
    var maxLength = Math.max(this.get('questionsViewing').length,
                             this.get('questionsComparing').length);
    for (var i = 0; i < maxLength; i++) {
      var question = {};
      question.viewing = null;
      if (this.get('questionsViewing')[i]) {
        question.viewing = this.get('questionsViewing')[i];
      }
      question.comparing = null;
      if (this.get('questionsComparing')[i]) {
        question.comparing = this.get('questionsComparing')[i];
      }
      this.get('questions')[i] = question;
    }
  },

  authors: Ember.computed('snapshot1', 'snapshot2', function() {
    let viewing = findAuthors(this.get('snapshot1.contents.children'))
      .sort(positionSort);

    let comparing = findAuthors(this.get('snapshot2.contents.children'));

    let addedAndChanged = viewing.map(function(viewingAuthor) {
      let comparingAuthor = equivalentAuthor(viewingAuthor, comparing);
      return {viewing: viewingAuthor, comparing: comparingAuthor};
    });

    let removed = comparing.reject((c) => {
       return equivalentAuthor(c, viewing);
    }).map((deletedAuthor) => {
      return {viewing: null, comparing: deletedAuthor};
    });

    return addedAndChanged.concat(removed);
  }),

  init: function() {
    this._super(...arguments);
    //this.setQuestions();
  }
});
