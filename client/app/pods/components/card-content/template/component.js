import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['card-content-template'],
  restless: Ember.inject.service('restless'),

  to: undefined,
  subject: undefined,
  body: undefined,

  _templateConfig(endpoint) {
    return {
      url: `/api/tasks/${this.get('owner.id')}/${endpoint}`,
      data: {
        ident: this.get('content.letterTemplateIdent'),
        taskId: this.get('owner.id')
      }
    };
  },

  didRender() {
    const config = this._templateConfig('render_template');
    this.get('restless').put(config.url, config.data).then((data)=> {
      this.set('to', data.to);
      this.set('subject', data.subject);
      this.set('body', data.body);
    });
  },

  actions: {}
});
