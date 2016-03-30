import Ember from 'ember';

const noRole = `The funder had no role in study design,
                data collection and analysis, decision to publish,
                or preparation of the manuscript`;

export default Ember.Component.extend({
  statement: Ember.computed('funder.funderHadInfluence', 'funder.funderInfluenceDescription', function() {
    if (this.get('funder.funderHadInfluence')) {
      return '. ' + this.get('funder.funderInfluenceDescription');
    }
    else if (this.get('funder.funderHadInfluence') === false) {
      return '. ' + noRole;
    }
  }),

  lastFunder: Ember.computed('funderCount', 'index', function() {
    return (this.get('index') === this.get('funderCount') - 1);
  })
});
