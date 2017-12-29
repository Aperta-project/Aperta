import ApplicationAdapter from 'tahi/adapters/application';

export default ApplicationAdapter.extend({
  pathForType() { return 'admin/letter_templates'; },

  preview(id, letter_template) {
    return this.ajax(this.urlForPreview(id), 'POST', { data: {letter_template} });
  },

  urlForPreview(id) {
    return `${this.buildURL('letter-template', id)}/preview`;
  }
});
