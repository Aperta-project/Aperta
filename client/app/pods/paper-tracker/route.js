import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return [{
      title: 'Life Changing Science Right Here Super Awesome Sauce Science Life Changing Science Right Here Super Awesome Sauce Science',
      id: 11111,
      dateSubmitted: new Date(),
      paperType: 'Research'
    }, {
      title: 'Super Awesome Sauce Science',
      id: 22222,
      dateSubmitted: new Date(),
      paperType: 'Besearch'
    }];
  }
});
