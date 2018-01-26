import Ember from 'ember';
import TechCheckBase from 'tahi/pods/components/tech-check-base/component';

export default TechCheckBase.extend({
  init() {
    this._super(...arguments);

    this.set(
      'authorChangesLetter',
      this.get('task.changesForAuthorTask.body.' + this.get('bodyKey'))
    );
  },

  bodyKey: 'initialTechCheckBody'
});
