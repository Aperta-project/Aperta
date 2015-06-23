import Ember from 'ember';

export default Ember.Mixin.create({
  _setupTopicsPaths: Ember.on('init', function() {
    // if not coming from subroute like edit or workflow: `paper`
    // else: `paper.subroute`
    let noSubRoute = Ember.isEmpty(this.get('subRouteName'));
    let parentPath = 'paper' + (noSubRoute ? '' : '.' + this.get('subRouteName'));
    let basePath   = parentPath + '.discussions';

    this.setProperties({
      topicsParentPath: parentPath,
      topicsIndexPath:  basePath,
      topicsNewPath:    basePath + '.new',
      topicsShowPath:   basePath + '.show'
    });
  })
});
