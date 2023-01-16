# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships

  has_many :tasks

  validates :name, presence: true
  # validate :admin_in_group
  enum membership_type: [:admin, :user]
  # def self.create_with_admin(params, user)
  #   group = Group.new(params)
  #   return group unless user
  #
  #   ActiveRecord::Base.transaction do
  #     group.save(validate: false)
  #     group.make_admin(user)
  #     raise ActiveRecord::Rollback unless group.valid?
  #   end
  #   group
  # end

  def group_membership_for(user)
    group_memberships.where(user: user).first
  end

  def admin?(user)
    admins.include? user
  end

  def confirmed_member?(user)
    confirmed_members.map(&:user).include? user
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
    group_memberships << GroupMembership.new(user: user)
  end

  def admins
    group_memberships.admin.map(&:user)
  end

  def confirmed_members
    group_memberships.admin.map(&:member)
  end

  def members
    group_memberships.map(&:member)
  end

  def pending_users
    group_memberships.applicant.map(&:member)
  end

  def remove_member(user)
    ActiveRecord::Base.transaction do
      group_membership_for(user)&.destroy
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
