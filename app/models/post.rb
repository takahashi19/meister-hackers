# frozen_string_literal: true

# == Schema Information
#
# Table name: posts
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  title      :string           not null
#  content    :text             not null
#  user_id    :bigint(8)        not null
#  repository :string           not null
#  status     :integer          default("wanted"), not null
#  owner      :string
#  opened_on  :date
#  closed_on  :date
#

class Post < ApplicationRecord
  enum status: { wanted: 1, stopped: 2 }
  belongs_to :user
  has_many :messages, dependent: :destroy

  validates :title, presence: true, length: { maximum: 50 }
  validates :content, presence: true, length: { maximum: 1000 }
  validates :repository, presence: true

  before_create :format_repository
  before_save :update_date

  def owner_and_repository
    [owner, repository].join("/")
  end

  def format_repository
    url_splits = self.repository.split("/")
    self.owner = url_splits[-2]
    self.repository = url_splits[-1]
  end

  def update_date
    if self.wanted?
      self.opened_on = Date.today
      self.closed_on = nil
    elsif self.stopped?
      self.closed_on = Date.today
    end
  end
end
