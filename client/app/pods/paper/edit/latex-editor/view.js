import Ember from 'ember';
import PaperEditMixin from 'tahi/mixins/views/paper-edit';

export default Ember.View.extend(PaperEditMixin, {
  timeoutSave() {
    this.get('controller').send('savePaper');
  }
});
