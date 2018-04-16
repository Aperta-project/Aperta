# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'
require 'data_migration'

describe DataMigration, rake: true do
  let(:klass) { Class.new(DataMigration) }

  context 'when `RAKE_TASK_UP` is not defined' do
    it 'fails on up' do
      expect { klass.new.up }.to raise_exception(NameError)
    end
  end

  context 'when `RAKE_TASK_UP` is not a string' do
    before do
      klass::RAKE_TASK_UP = nil
    end

    it 'fails on up' do
      expect { klass.new.up }.to raise_exception(/RAKE_TASK_UP is not defined/)
    end
  end

  context 'when `RAKE_TASK_UP` is defined' do
    let(:task_name) { SecureRandom.hex(10) }

    before do
      klass::RAKE_TASK_UP = task_name
    end

    context 'but the task does not exist' do
      it 'warns' do
        expect(Rails.logger).to receive(:warn)
        expect(klass.new.up).to be(nil)
      end
    end

    context 'and the task exists' do
      let(:underlying_code) { double }
      before do
        Rake::Task.define_task(task_name) do
          underlying_code.call
        end
      end

      it 'should be called' do
        expect(underlying_code).to receive(:call)
        ActiveRecord::Migration.suppress_messages { klass.new.up }
      end
    end
  end

  context 'when `RAKE_TASK_DOWN` is not defined' do
    it 'does nothing' do
      klass.new.down
    end
  end

  context 'when `RAKE_TASK_DOWN` is defined' do
    let(:task_name) { SecureRandom.hex(10) }

    before do
      klass::RAKE_TASK_DOWN = task_name
    end

    context 'but the task does not exist' do
      it 'warns' do
        expect(Rails.logger).to receive(:warn)
        klass.new.down
      end
    end

    context 'and the task exists' do
      let(:underlying_code) { double }
      before do
        Rake::Task.define_task(task_name) do
          underlying_code.call
        end
      end

      it 'should be called' do
        expect(underlying_code).to receive(:call)
        ActiveRecord::Migration.suppress_messages { klass.new.down }
      end
    end
  end
end
