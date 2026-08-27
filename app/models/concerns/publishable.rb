module Publishable
  extend ActiveSupport::Concern

  PRIVATE = 0
  PUBLIC  = 1

  included do
    scope :publicly_visible, -> { where(public_status: PUBLIC) }
  end

  def publicly_visible?
    public_status.to_i == PUBLIC
  end
end
