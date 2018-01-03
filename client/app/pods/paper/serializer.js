import ApplicationSerializer from 'tahi/pods/application/serializer';

export default ApplicationSerializer.extend({
  attrs: {
    authors: { serialize: false },
    collaborations: { serialize: false },
    figures: { serialize: false },
    phases: { serialize: false },
    supportingInformationFiles: { serialize: false },
    tasks: { serialize: false },
    versionsContainPdf: { serialize: false }
  }
});
