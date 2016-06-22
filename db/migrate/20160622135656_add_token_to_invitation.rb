# Token used to be 'code', but token is more suggestive of
# a single use, so we're going with that.
class AddTokenToInvitation < ActiveRecord::Migration
  def change
    change_table :invitations do |t|
      t.string :token, index: true
    end
  end
end
