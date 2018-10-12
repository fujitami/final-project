class LatestAlbumsService
  def initialize(latest_taggable_id)
    @taggable_id = latest_taggable_id.sort {|a, b| b <=> a }
  end

  def get_latest_albums_spotify_id
    spotify_ids = []
    @taggable_id.each do |taggable_id|
      spotify_id = Album.includes(:taggings).where('taggings.taggable_id = ?', taggable_id).references(:taggings).pluck(:spotify_id)
      spotify_ids << spotify_id
    end
    latest_spotify_id = spotify_ids.flatten
  end

  def get_latest_albums_tag
    tags = []
    @taggable_id.each do |taggable_id|
      tag = ActsAsTaggableOn::Tagging.where('taggable_id = ?', taggable_id).pluck(:tag_id)
      tags << tag
    end
    latest_tag_id = tags.flatten
  end
end
