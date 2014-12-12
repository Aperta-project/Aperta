`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`

DocumentDownloadService = Ember.Namespace.create
  initiate: (paperId, downloadFormat) ->
    @paperId = paperId
    @downloadFormat = downloadFormat
    Ember.$.ajax
      url: "/papers/#{@paperId}/export",
      data: {format: @downloadFormat}
      success: (data) =>
        jobId = data['jobs']['id']
        @checkJobStatus(jobId)
      error: (data) ->
        throw new Error("Could not download #{@downloadFormat}")

  checkJobStatus: (jobId) ->
    status = ""
    @timeout = 2000
    Ember.$.ajax
      url: "/papers/#{@paperId}/status/#{jobId}",
      success: (data) =>
        job = data['jobs']
        if job.status == "complete"
          Utils.windowLocation job.url
        else if job.status == "working"
          setTimeout (=>
            @checkJobStatus jobId
          ), @timeout
        else
          throw new Error("Unknown conversion status #{job.status}")

`export default DocumentDownloadService`
