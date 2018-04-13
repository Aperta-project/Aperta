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

describe TaskTemplate do
  describe 'Configurable mixin' do
    let(:journal_task_type) { FactoryGirl.create(:journal_task_type) }
    let(:configurable) do
      FactoryGirl.create(:task_template, journal_task_type: journal_task_type)
    end

    it 'destroys its settings when it is destroyed' do
      FactoryGirl.create(:setting, owner: configurable)

      configurable.destroy!
      expect(Setting.count).to eq(0)
    end

    describe 'setting(name)' do
      let(:result) do
        configurable.setting(setting_name)
      end
      context 'with an existing Setting' do
        let(:setting_name) { 'foo_setting' }
        let!(:existing_setting) do
          FactoryGirl.create(:setting, name: setting_name, value: 'foo-on', owner: configurable)
        end

        it 'does not create a new Setting, but returns the existing one' do
          expect { result }.to_not change { Setting.count }
          expect(result.id).to eq(existing_setting.id)
          expect(result.value).to eq('foo-on')
        end
      end

      context 'with a corresponding SettingTemplate' do
        let(:setting_name) { 'foo_setting' }
        let!(:setting_template) do
          FactoryGirl.create(:setting_template,
                             setting_name: setting_name,
                             key: configurable.setting_template_key,
                             value: "foo")
        end

        it 'creates a new Setting in the db' do
          expect { result }.to change { Setting.count }.by(1)
        end

        it 'sets the default value for named setting from the template' do
          expect(result.value).to eq("foo")
        end

        it 'associates the new setting to the setting template' do
          expect(result.setting_template).to eq(setting_template)
        end
      end

      context 'with a corresponding integer settingTemplate' do
        let(:setting_name) { 'bar_setting' }
        let!(:setting_template) do
          FactoryGirl.create(:setting_template,
                             setting_name: setting_name,
                             key: configurable.setting_template_key,
                             value_type: 'integer',
                             value: 42)
        end

        it '#all_settings returns all settings' do
          expect(configurable.all_settings).to eq([{ name: 'bar_setting', value: 42 }])
        end

        it 'sets the default value for named setting from the template' do
          expect(result.value).to eq(42)
        end
      end
    end
  end

  describe 'custom validations' do
    describe 'card relationships' do
      let(:card) { FactoryGirl.create(:card) }
      let(:journal_task_type) { FactoryGirl.create(:journal_task_type) }

      it 'is invalid if associated to both a card and journal task type' do
        task_template = FactoryGirl.build(:task_template, card: card, journal_task_type: journal_task_type)
        expect(task_template).to be_invalid
      end

      it 'is invalid if associated to neither a card nor journal task type' do
        task_template = FactoryGirl.build(:task_template, card: nil, journal_task_type: nil)
        expect(task_template).to be_invalid
      end

      it 'is valid if associated to just a card' do
        task_template = FactoryGirl.build(:task_template, card: card, journal_task_type: nil)
        expect(task_template).to be_valid
      end

      it 'is valid if associated to just a journal task type' do
        task_template = FactoryGirl.build(:task_template, card: nil, journal_task_type: journal_task_type)
        expect(task_template).to be_valid
      end
    end
  end
end
