ETahi.PaperReviewerTask = ETahi.Task.extend
  reviewers: DS.hasMany('user')
  relationshipsToSerialize: ['reviewers', 'participants']
