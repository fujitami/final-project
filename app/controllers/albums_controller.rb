class AlbumsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tag, only: [:create]

  def show
    @btn_disabled = 0
    respond_to do |format|
      format.html
      format.json {
        if Album.includes(:taggings).where('taggings.tagger_id = ?', current_user.id).references(:taggings).where(spotify_id: params[:id]).exists?
          @btn_disabled = 1
        end
      }
    end
  end

  # albumsテーブルにアルバム情報のレコード追加(タグ・ユーザとの関連付けも含む)
  def create
    @album = Album.new(spotify_id: params[:spotify_id])
    user = current_user
    #current_userのbanカラムに値が入っているとき→タグ付けを保存しない
    if User.where('id = ?', user.id).where(ban: 'ban').exists?
      redirect_to root_path, alert: ''
    else
      unless Album.includes(:taggings).where('taggings.tagger_id = ?', user.id).references(:taggings).where(spotify_id: params[:spotify_id]).exists?
        tag_list = @album.tags_from(user)
        tag_list.add(@tag)
        user.tag(@album, with: tag_list, on: :tags)
      end
      # ログイン中ユーザによって1分間に10回投稿がされた場合、そのユーザを凍結する
      @spam_judge = Album.includes(:taggings).where('taggings.tagger_id = ?', user.id).references(:taggings).where(created_at: Time.current.to_datetime.beginning_of_minute..Time.current.to_datetime.end_of_minute).count()
      if @spam_judge > 10
        user.ban = 'ban'
        user.save
      end
    end
  end

  private

  def album_params
    params.require(:album).permit(
      :id,
      :spotify_id,
      users_attributes: [:id, :ban]
    )
  end

  def set_tag
    @tag = ActsAsTaggableOn::Tag.find(params[:tag_id])
  end

end
