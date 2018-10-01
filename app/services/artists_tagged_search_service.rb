class ArtistsTaggedSearchService
  def initialize(album_id)
    @album_id = album_id
  end

  def get_most_tagged_tag_id
    album_grouping_tagged_tag_id = Album.includes(:taggings).where(spotify_id: @album_id).references(:taggings).group(:tag_id)
    most_tagged_tag_id = album_grouping_tagged_tag_id.order('count_id desc').count().keys.first
  end
end
