class Post < ApplicationRecord
  validates_presence_of :title
  validates_presence_of :body

  after_create :invalidate_cache
  after_destroy :invalidate_cache

  private
  def invalidate_cache
    Rails.cache.delete("posts_count")
    true
  end

  def self.posts_count
    Rails.cache.fetch("posts_count") do
      Post.count
    end
  end

end
