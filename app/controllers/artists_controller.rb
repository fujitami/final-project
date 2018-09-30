class ArtistsController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  # アルバムに最も多くついたタグのidを抽出
  def tagged_search
    album_id = params[:id]
    @most_tagged_tag_id = ArtistsTaggedSearchService.new(album_id).get_most_tagged_tag_id
    respond_to do |format|
      format.html
      format.json
    end
  end

end
