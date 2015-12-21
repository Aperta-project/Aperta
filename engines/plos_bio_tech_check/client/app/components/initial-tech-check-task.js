import Ember from 'ember';
import TechCheckBase from 'tahi/components/tech-check-base';

export default TechCheckBase.extend({
  init() {
    this._super(...arguments);

    this.set(
      'authorChangesLetter',
      this.get('task.changesForAuthorTask.body.' + this.get('bodyKey'))
    );
  },

  emailEndpoint: 'initial_tech_check',
  bodyKey: 'initialTechCheckBody'
});
