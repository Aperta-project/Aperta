import Ember from 'ember';

const { computed } = Ember;
const { filterBy, union, sort } = computed;

export default Ember.Component.extend({
  snapshot1: null, //Snapshots are passed in
  snapshot2: null,
  questions: Ember.A(),
  authors: Ember.A(),

  authorSorting: ['position', 'id', 'type'],
  sortedAuthors: sort('authors', 'authorSorting'),

  questionsViewing: filterBy('snapshot1.contents.children','type','question'),

  questionsComparing: filterBy('snapshot2.contents.children','type','question'),

  unsortedAuthorsViewing: filterBy('snapshot1.contents.children',
                                   'name', 'author'),
  unsortedGroupAuthorsViewing: filterBy('snapshot1.contents.children',
                                        'name', 'group-author'),
  unsortedViewing: union('unsortedAuthorsViewing',
                         'unsortedGroupAuthorsViewing'),

  unsortedAuthorsComparing: filterBy('snapshot2.contents.children',
                                     'name', 'author'),
  unsortedGroupAuthorsComparing: filterBy('snapshot2.contents.children',
                                          'name', 'group-author'),
  unsortedComparing: union('unsortedAuthorsComparing',
                           'unsortedGroupAuthorsComparing'),

  diffSorting: ['id', 'type'],
  diffViewing: sort('unsortedViewing', 'diffSorting'),
  diffComparing: sort('unsortedComparing', 'diffSorting'),

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

  setAuthors: function() {
    for (var i = 0; i < this.get('diffViewing').length; i++) {
      var author = {};
      author.viewing = this.get('diffViewing')[i];
      author.comparing = _.findWhere(this.get('diffComparing'),
                        {id: author.viewing.id, type: author.viewing.type});
      this.get('authors')[i] = author;
    }
    var lastAuthor = this.get('diffViewing').length;
    for (var i = 0; i < this.get('diffComparing').length; i++) {
      var compare = this.get('diffComparing')[i];
      var viewing = _.findWhere(this.get('diffViewing'),
                                {id: compare.id, type: compare.type});
      if (!viewing) {
        var author = {};
        author.viewing = { name: compare.name };
        author.comparing = compare;
        this.get('authors')[lastAuthor] = author;
        lastAuthor++;
      }
    }
  },

  init: function() {
    this._super(...arguments);
    this.setQuestions();
    this.setAuthors();
  }
});
