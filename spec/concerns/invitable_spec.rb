require 'rails_helper'

describe Invitable do
  let (:invitable_task) { create :invitable_task }
  describe '#invitee_role' do
    context 'when it is not implemented in the task' do
      it 'raises a NotImplementedError' do
        expect{ invitable_task.invitee_role }.to raise_error NotImplementedError
      end
    end

    context 'when it is implemented in the task' do
      it 'does not raise NotImplementedError' do
        allow(invitable_task).to receive(:invitee_role).and_return 'editor'
        expect{ invitable_task.invitee_role }.not_to raise_error
      end
    end
  end
end
