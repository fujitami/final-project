require 'rails_helper'

describe ArtistsController, type: :controller do
  describe 'GET #show' do
    it 'renders the :show template' do
      artist = create(:artist)
      get :show, params: {name: artist}
      expect(response).to render_template :show
    end
  end
end
# 上記は失敗する
# Railsでアーティストのspotify_idを受け渡しているわけではないから、テストできない？
