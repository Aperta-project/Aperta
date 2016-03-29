import Ember from 'ember';

const { computed } = Ember;
const {
  alias,
  and,
  equal,
  filterBy,
  not,
  or,
  setDiff,
  sort
} = computed;

export default Ember.Component.extend({
  snapshot1: null, //Snapshots are passed in
  snapshot2: null,
  authors: Ember.A(),

  unsortedAuthorsViewing: Ember.computed('snapshot1.contents.children', function() {
    var that = this;
    return _.filter(_.map(this.get('snapshot1.contents.children'), function(o) {
      return that.diffableAuthor(o);
    })
  );}),

  unsortedAuthorsComparing: Ember.computed('snapshot2.contents.children', function() {
    var that = this;
    return _.filter(_.map(this.get('snapshot2.contents.children'), function(o) {
      return that.diffableAuthor(o);
    })
  );}),

  authorSorting: ['position'],
  authorsViewing: sort('unsortedAuthorsViewing', 'authorSorting'),
  authorsComparing: sort('unsortedAuthorsComparing', 'authorSorting'),

  diffableAuthor: function(o) {
    if (o.name === 'author') {
      return {
        name: this.getName(
          this.fromProperty(o, 'first_name').value,
          this.fromProperty(o, 'middle_initial').value,
          this.fromProperty(o, 'last_name').value),
        email: this.fromProperty(o, 'email').value,
        position: this.fromProperty(o, 'position').value,
        id: this.fromProperty(o, 'id').value,
        corresponding: this.fromQuestion(o,
          'author--published_as_corresponding_author'),
        deceased: this.fromQuestion(o, 'author--deceased'),
        contributions: this.getContributions(o),
        title: this.fromProperty(o, 'title').value,
        department: this.fromProperty(o, 'department').value,
        affiliation: this.fromProperty(o, 'affiliation').value,
        secondaryAffiliation:
          this.fromProperty(o, 'secondary_affiliation').value,
        government: this.fromQuestion(o, 'author--government-employee'),
        type: 'Author'
      };
    } else if (o.name === 'group-author') {
      return {
        name: this.getName(
          this.fromProperty(o, 'contact_first_name').value,
          this.fromProperty(o, 'contact_middle_name').value,
          this.fromProperty(o, 'contact_last_name').value),
        email: this.fromProperty(o, 'contact_email').value,
        position: this.fromProperty(o, 'position').value,
        id: this.fromProperty(o, 'id').value,
        corresponding: ' ',
        deceased: ' ',
        title: ' ',
        department: ' ',
        affiliation: ' ',
        secondaryAffiliation: ' ',
        contributions: this.getContributions(o),
        government: this.fromQuestion(o,
          'group-author--government-employee'),
        type: 'Group Author'
      };
    }
    return false;
  },

  getName: function(first, middle, last) {
    if (!first) {
      first = '';
    }
    if (!middle) {
      middle = '';
    }
    if (!last) {
      last = '';
    }
    return first + ' ' + middle + ' ' + last;
  },

  fromProperty: function(author, name) {
    var property = _.find(author.children, function(o) {
      return o.name === name;
    });
    if (property) {
      return property;
    }
    return null;
  },

  fromQuestion: function(author, name) {
    var question = this.fromProperty(author, name);
    if (question && question.value && question.value.answer) {
      return question.value.title;
    }
    return null;
  },

  getContributions: function(author) {
    var response = '';
    var contributions = this.fromProperty(author, 'author--contributions');
    if (author.name === 'group-author') {
      contributions = this.fromProperty(author, 'group-author--contributions');
    }
    if (contributions) {
      _.each(contributions.children, function(contribution) {
        if (contribution.value.answer) {
          response += contribution.value.title + ', ';
        }
      });
      if (response.endsWith(', ')) {
        response = response.substring(0, response.length - 2);
      }
    }
    return response;
  },

  setAuthors: function() {
    var authors = Ember.A();
    var maxLength = Math.max(this.get('authorsViewing').length,
                             this.get('authorsComparing').length);
    for (var i = 0; i < maxLength; i++) {
      var author = {};
      author.viewing = this.emptyAuthor(i + 1);
      author.comparing = this.emptyAuthor(i + 1);
      if (this.get('authorsViewing')[i]) {
        author.viewing = this.get('authorsViewing')[i];
        author.viewing.displayPosition = i + 1;
      }
      if (this.get('authorsComparing')[i]) {
        author.comparing = this.get('authorsComparing')[i];
        author.comparing.displayPosition = i + 1;
      }
      authors[i] = author;
    }
    this.set('authors', authors);
  },

  emptyAuthor: function(displayPosition) {
    return {
      name: '',
      position: Number.MAX_SAFE_INTEGER,
      displayPosition: displayPosition,
      id: 0,
      type: '',
      title: '',
      department: '',
      affiliation: '',
      secondaryAffiliation: '',
      government: ''
    };
  },

  init: function() {
    this._super(...arguments);
    this.setAuthors();
  }
});
