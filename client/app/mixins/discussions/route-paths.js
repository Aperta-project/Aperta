import Ember from 'ember';

export default Ember.Mixin.create({
  init() {
    this._setupTopicsPaths();
    this._super(...arguments);
  },

  paperModel() {
    return this.modelFor('paper');
  },

  topicsBasePath() {
    return 'paper.' + this.get('subRouteName') + '.discussions.';
  },

  _setupTopicsPaths() {
    let base = this.topicsBasePath();

    this.setProperties({
      topicsParentPath: 'paper.' + this.get('subRouteName'),
      topicsIndexPath:  base + 'index',
      topicsNewPath:    base + 'new',
      topicsShowPath:   base + 'show'
    });
  }
});
