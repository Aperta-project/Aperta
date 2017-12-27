import Ember from 'ember';
import TechCheckBase from 'tahi/components/tech-check-base';

export default TechCheckBase.extend({
  emailEndpoint: 'revision_tech_check',
  bodyKey: 'revisedTechCheckBody'
});
