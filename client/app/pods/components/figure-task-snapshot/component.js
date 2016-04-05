import Ember from 'ember';

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  classNames: ['figure-snapshot'],

  children: Ember.computed(
    'snapshot1.children',
    'snapshot2.children',
    function(){
      return _.zip(
        this.get('snapshot1.children'),
        this.get('snapshot2.children') || []);
    }
  ),

  figures1: Ember.computed.filterBy('snapshot1.children', 'name', 'figure'),
  figures2: Ember.computed.filterBy('snapshot2.children', 'name', 'figure'),

  figures: Ember.computed('figures1', 'figures2', function(){
    return _.zip(this.get('figures1'), this.get('figures2'));
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
