import Ember from 'ember';

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

  questions: Ember.computed('snapshot1', 'snapshot2', function() {
    let viewing = this.get('snapshot1.contents.children')
      .filterBy('type', 'question');
    let comparing = this.get('snapshot2.contents.children')
      .filterBy('type', 'question');
    let addedAndChanged = viewing.map(function(viewingQuestion) {
      return {
        viewing: viewingQuestion,
        comparing: comparing.findBy('name', viewingQuestion.name)
      };
    });

    let removed = comparing.reject((c) => {
      return viewing.findBy('name', c.name);
    }).map((deletedQuestion) => {
      return {viewing: null, comparing: deletedQuestion};
    });

    return addedAndChanged.concat(removed);
  }),

  authors: Ember.computed('snapshot1', 'snapshot2', function() {
    let viewing = findAuthors(this.get('snapshot1.contents.children'))
      .sort(positionSort);

    let comparing = findAuthors(this.get('snapshot2.contents.children'));

    let addedAndChanged = viewing.map(function(viewingAuthor) {
      return {
        viewing: viewingAuthor,
        comparing: equivalentAuthor(viewingAuthor, comparing)
      };
    });

    let removed = comparing.reject((c) => {
       return equivalentAuthor(c, viewing);
    }).map((deletedAuthor) => {
      return {viewing: null, comparing: deletedAuthor};
    });

    return addedAndChanged.concat(removed);
  })
});
