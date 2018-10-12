class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    user = current_user
    @current_user_album_ids_hash = UsersShowService.new(user).get_album_ids #ユーザがタグ付けしたアルバム一覧の取得
    @current_user_tag_id_color = UsersShowService.new(user).get_tag_id_color #ユーザが最も多くつけたタグに対応する色の取得
    respond_to do |format|
      format.html
      format.json
    end
  end

end
