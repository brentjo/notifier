class User < ApplicationRecord
  has_secure_password
  has_many :notifications, dependent: :destroy

  before_validation :strip_whitespace_downcase_email

  validates :email, presence: true, uniqueness: true
  validates :password, :presence => true,
                         :length => {:within => 8..150},
                         :on => :create

  private

  def strip_whitespace_downcase_email
    self.email = self.email.strip unless self.email.nil?
    self.email = email.downcase if email.present?
  end

end
