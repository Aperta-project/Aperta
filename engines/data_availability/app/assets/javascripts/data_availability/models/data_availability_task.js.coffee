ETahi.DataAvailabilityTask = ETahi.Task.extend
  questions: null
  initQuestions: (-> @set('questions', [])).on('init')
