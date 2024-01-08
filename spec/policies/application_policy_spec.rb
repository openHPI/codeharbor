# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationPolicy do
  describe '#initialize' do
    context 'without a user' do
      it 'raises an error' do
        expect { described_class.new(nil, nil) }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe '#methods_missing' do
    subject(:policy) { described_class.new(create(:user), nil) }

    it 'returns false for all default actions' do
      %i[index? create? new? update? edit? destroy?].each do |action|
        expect(policy.send(action)).to be false
      end
    end

    it 'responds to all default actions' do
      %i[index? create? new? update? edit? destroy?].each do |action|
        expect(policy).to respond_to(action)
      end
    end

    it 'raises an error for undefined non-default actions' do
      expect { policy.some_undefined_action? }.to raise_error(NoMethodError)
    end

    it 'does not respond to undefined actions' do
      expect(policy).not_to respond_to(:some_undefined_action?)
    end
  end
end
