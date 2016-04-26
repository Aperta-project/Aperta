import Ember from 'ember';
import SnapshotsById from 'tahi/lib/snapshots/snapshots-by-id';

export default Ember.Component.extend({
  snapshot1: null, //Snapshots are passed in
  snapshot2: null,

  questionsViewing: Ember.computed('snapshot1', function() {
    if (this.get('snapshot1')) {
      return this.get('snapshot1.children').filterBy('type', 'question');
    }
  }),

  questionsComparing: Ember.computed('snapshot2', function() {
    if (this.get('snapshot2')) {
      return this.get('snapshot2.children').filterBy('type', 'question');
    }
  }),

  questions: Ember.computed('questionsViewing', 'questionsComparing',
                            function() {
    return _.zip(this.get('questionsViewing'),
                 this.get('questionsComparing') || []);
  }),

  authors: Ember.computed('snapshot1', 'snapshot2', function() {
    var authorSnapshots = new SnapshotsById('author');
    var groupSnapshots = new SnapshotsById('group-author');

    authorSnapshots.addSnapshots(this.get('snapshot1.children'));
    groupSnapshots.addSnapshots(this.get('snapshot1.children'));

    if (this.get('snapshot2.children')) {
      authorSnapshots.addSnapshots(this.get('snapshot2.children'));
      groupSnapshots.addSnapshots(this.get('snapshot2.children'));
    }

    var authors = authorSnapshots.toArray();
    var groupAuthors = groupSnapshots.toArray();

    var allAuthors = authors.concat(groupAuthors);
    return _.sortBy(allAuthors, function(author) {
      if (author[0]) {
        return _.find(author[0].children, function(item) {
          return item.name === 'position';
        }).value;
      }
      return Number.MAX_SAFE_INTEGER; // Sort removed authors to the bottom
    });
  })
});
