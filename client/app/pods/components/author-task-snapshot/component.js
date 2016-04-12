import Ember from 'ember';
import SnapshotsById from 'tahi/lib/snapshots/snapshots-by-id';

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
