import Ember from 'ember';

export default Ember.Mixin.create({
  init() {
    this._setupTopicsPaths();
    this._super(...arguments);
  },

  paperModel() {
    return this.modelFor('paper');
  },

  makeBasePath() {
    return 'paper.' + this.get('subRouteName') + '.discussions';
  },

  _setupTopicsPaths() {
    let base = this.makeBasePath();

    this.setProperties({
      topicsParentPath: 'paper.' + this.get('subRouteName'),
      topicsBasePath:   base,
      topicsIndexPath:  base + '.index',
      topicsNewPath:    base + '.new',
      topicsShowPath:   base + '.show'
    });
  }
});
