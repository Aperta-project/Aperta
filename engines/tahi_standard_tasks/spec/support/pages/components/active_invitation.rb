# Represents a row in the table of active invitations for editors,
# reviewers, etc
class ActiveInvitation < PageFragment
  def self.with_header(text)
    el = Capybara.current_session.find('.active-invitations .invitation-item', text: text)
    new(el)
  end

  def self.for_user(user)
    yield with_header(user.full_name)
  end

  def show_details
    find('.invitation-item-full-name').click
  end

  def edit
    find('.invitation-item-action-edit').click
  end

  def upload_attachment(file_name)
    upload_file(element_id: 'file',
                file_name: file_name,
                sentinel: proc { InvitationAttachment.count })
    within('.attachment-item') do
      expect(page).to have_css('.file-link', text: file_name)
    end
  end
end
