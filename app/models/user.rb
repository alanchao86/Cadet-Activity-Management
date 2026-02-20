# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :unit
  has_many :activity_histories, dependent: :destroy
  has_many :training_activities, through: :activity_histories
  has_secure_password validations: false

  before_validation :normalize_username

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :provider, presence: true, inclusion: { in: %w[local google_oauth2 preloaded_google] }
  validates_inclusion_of :admin_flag, in: [true, false]
  validates :username, presence: true, if: :local_auth?
  validates :username, uniqueness: { case_sensitive: false }, allow_blank: true
  validates :password, presence: true, confirmation: true, if: :password_required?
  validates :uid, presence: true, uniqueness: { scope: :provider }, if: :google_auth?
  validates :uid, uniqueness: { scope: :provider }, allow_blank: true

  def units
    return unit.units if unit

    []
  end

  def local_auth?
    provider == 'local'
  end

  def google_auth?
    provider == 'google_oauth2'
  end

  def preloaded_google_auth?
    provider == 'preloaded_google'
  end

  private

  def normalize_username
    return if username.blank?

    self.username = username.strip.downcase
  end

  def password_required?
    return false unless local_auth?

    new_record? || password.present? || password_confirmation.present? || password_digest.blank?
  end
end
