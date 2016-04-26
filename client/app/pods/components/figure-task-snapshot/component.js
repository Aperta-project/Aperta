import Ember from 'ember';
import SnapshotsById from 'tahi/lib/snapshots/snapshots-by-id'

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  classNames: ['figure-snapshot'],

  figures: Ember.computed('figures1', 'figures2', function(){
    var snapshots = new SnapshotsById('figure');
    snapshots.addSnapshots(this.get('snapshot1.children'));

    if (this.get('snapshot2.children')) {
      snapshots.addSnapshots(this.get('snapshot2.children'));
    }

    return snapshots.toArray();
  }),

  notFigures1: Ember.computed.filter('snapshot1.children', function(child){
    return child.name !== "figure";
  }),
  notFigures2: Ember.computed.filter('snapshot2.children', function(child){
    return child.name !== "figure";
  }),

  notFigures: Ember.computed('notFigures1', 'notFigures2', function(){
    return _.zip(this.get('notFigures1'), this.get('notFigures2'));
  })
});
