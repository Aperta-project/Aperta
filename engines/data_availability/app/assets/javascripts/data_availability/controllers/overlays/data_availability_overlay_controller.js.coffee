ETahi.DataAvailabilityOverlayController = ETahi.TaskController.extend
  question1:(->
    @get("content.questions.firstObject")
  ).property('content.questions.@each')

  initQuestions:(->
  ).observes('content')

