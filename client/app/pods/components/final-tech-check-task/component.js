import Ember from 'ember';
import TechCheckBase from 'tahi/pods/components/tech-check-base/component';

export default TechCheckBase.extend({
  emailEndpoint: 'final_tech_check',
  bodyKey: 'finalTechCheckBody'
});
