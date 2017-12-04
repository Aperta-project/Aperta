import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['card-content-tech-check-email-view'],
  restless: Ember.inject.service('restless'),

  body: undefined,

  didRender() {
    const config = this._templateConfig('sendback_preview');
    this.get('restless').put(config.url, config.data).then((data)=> {
      this.set('body', data.body);
    });
  },

  _templateConfig(endpoint) {
    let task_id = this.get('owner.answers.firstObject.value');

    return {
      url: `/api/tasks/${task_id}/${endpoint}`
    };
  },
});

//enforce email structure in .rnc
