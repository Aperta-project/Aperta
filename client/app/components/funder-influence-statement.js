import Ember from 'ember';

const noRole = `
  <p>
    The funder had no role in study design, data collection and analysis,
    decision to publish, or preparation of the manuscript
  </p>
  `;

export default Ember.Component.extend({
  statement: Ember.computed('funder.funderHadInfluence', 'funder.funderInfluenceDescription', function() {
    if (this.get('funder.funderHadInfluence')) {
      const description = this.get('funder.funderInfluenceDescription');
      if (description) {
        return description;
      }
    }
    return noRole;
  })
});
