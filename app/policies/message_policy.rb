# frozen_string_literal: true

class MessagePolicy < ApplicationPolicy
  def message
    @record
  end

  %i[index? new?].each do |action|
    define_method(action) { everyone }
  end

  def create?
    @user == message.sender || admin?
  end

  def reply?
    Message.received_by(@user).sent_by(message.recipient).present? || admin?
  end

  def destroy?
    @user == message.sender || @user == message.recipient || admin?
  end
end
