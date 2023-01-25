# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships

  has_many :group_tasks, dependent: :destroy
  has_many :tasks, through: :group_tasks

  validates :name, presence: true
  validate :admin_in_group

  def add(user, role: :member)
    group_memberships << GroupMembership.new(user:, role:)
  end

  def group_membership_for(user)
    group_memberships.where(user:).first
  end

  def admin?(user)
    admins.include? user
  end

  def confirmed_member?(user)
    confirmed_members.include? user
  end

  def member?(user)
    members.include? user
  end

  def make_admin(user)
    group_membership_for(user)&.admin!
  end

  def grant_access(user)
    group_membership_for(user)&.member!
  end

  def add_pending_user(user)
    group_memberships << GroupMembership.new(user:)
  end

  def admins
    group_memberships.select(&:admin?).map(&:user)
  end

  def confirmed_members
    group_memberships.select(&:member?).map(&:user)
  end

  def members
    group_memberships.map(&:user)
  end

  def pending_users
    group_memberships.select(&:applicant?).map(&:user)
  end

  def remove_member(user)
    ActiveRecord::Base.transaction do
      group_membership_for(user)&.destroy
      reload
      validate!
    end
  end

  def last_admin?(user)
    group_membership_for(user).admin? && admins.size == 1
  end

  private

  def admin_in_group
    errors.add(:base, I18n.t('groups.no_admin_validation')) if admins.empty?
  end
end
