import Ember from 'ember';

export default Ember.Mixin.create({
  _setupTopicsPaths: Ember.on('init', function() {
    let base = 'paper.' + this.get('subRouteName') + '.discussions.';

    this.setProperties({
      topicsParentPath: 'paper.' + this.get('subRouteName'),
      topicsIndexPath:  base + 'index',
      topicsNewPath:    base + 'new',
      topicsShowPath:   base + 'show'
    });
  })
});
