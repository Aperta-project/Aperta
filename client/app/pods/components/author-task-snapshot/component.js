import Ember from 'ember';
import SnapshotsById from 'tahi/lib/snapshots/snapshots-by-id';

export default Ember.Component.extend({
  snapshot1: null, //Snapshots are passed in
  snapshot2: null,

  questionsViewing: Ember.computed('snapshot1', function() {
    return this.get('snapshot1.contents.children').filterBy(
      'type', 'question');
  }),

  questionsComparing: Ember.computed('snapshot2', function() {
    return this.get('snapshot2.contents.children').filterBy(
      'type', 'questions');
  }),

  questions: Ember.computed('questionsViewing', 'questionsComparing',
                            function() {
    return _.zip(this.get('questionsViewing'),
                 this.get('questionsComparing') || []);
  }),

  authors: Ember.computed('snapshot1', 'snapshot2', function() {
    var snapshots = new SnapshotsById('author');
    snapshots.addSnapshots(this.get('snapshot1.contents.children'));
    snapshots.addSnapshots(this.get('snapshot2.contents.children'));
    var authors = snapshots.toArray();

    snapshots = new SnapshotsById('group-author');
    snapshots.addSnapshots(this.get('snapshot1.contents.children'));
    snapshots.addSnapshots(this.get('snapshot2.contents.children'));
    var groupAuthors = snapshots.toArray();

    var allAuthors = authors.concat(groupAuthors);
    return _.sortBy(allAuthors, function(author) {
      return _.find(author[0].children, function(item) {
        return item.name === 'position';
      }).value;
    });
  })
});
