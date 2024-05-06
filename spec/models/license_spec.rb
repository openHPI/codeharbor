# frozen_string_literal: true

require 'rails_helper'

RSpec.describe License do
  describe '#destroy' do
    subject(:destroy) { license.destroy }

    let!(:license) { create(:license) }

    it 'deletes license' do
      expect { destroy }.to change(described_class, :count).by(-1)
    end

    it 'does not delete license referred to by a task' do
      create(:task, license:)
      expect { destroy }.not_to change(described_class, :count)
    end
  end
end
