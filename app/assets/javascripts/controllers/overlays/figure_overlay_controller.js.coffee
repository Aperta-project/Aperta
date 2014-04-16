ETahi.FigureOverlayController = ETahi.TaskController.extend
  actions:
    destroyFigure: (figure)->
      figure.destroyRecord()
