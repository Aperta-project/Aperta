import Ember from 'ember';
import TechCheckBase from 'tahi/components/tech-check-base';

export default TechCheckBase.extend({
  emailEndpoint: 'final_tech_check',
  bodyKey: 'finalTechCheckBody'
});
