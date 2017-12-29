import Ember from 'ember';
import TechCheckBase from 'tahi/pods/components/tech-check-base/component';

export default TechCheckBase.extend({
  emailEndpoint: 'revision_tech_check',
  bodyKey: 'revisedTechCheckBody'
});
