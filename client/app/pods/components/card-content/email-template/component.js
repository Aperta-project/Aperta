import Ember from 'ember';
import QAIdent from 'tahi/mixins/components/qa-ident';

export default Ember.Component.extend(QAIdent, {
  classNames: ['card-content-template'],
  restless: Ember.inject.service('restless'),

  body: undefined,

  _templateConfig(endpoint) {
    return {
      url: `/api/tasks/${this.get('owner.id')}/${endpoint}`,
      data: {
        ident: this.get('content.letterTemplate'),
      }
    };
  },

  didRender() {
    const config = this._templateConfig('render_template');
    this.get('restless').put(config.url, config.data).then((data)=> {
      this.set('body', data.letter_template.body);
    });
  }
});
