# this should always come first as it initializers email headers
# and such that may be consumed further on down the line
MailLog::InitializeMessage.attach_handlers!

MailLog::LogToRails.attach_handlers!
MailLog::LogToDatabase.attach_handlers!
