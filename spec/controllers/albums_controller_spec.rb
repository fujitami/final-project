require 'rails_helper'

describe AlbumsController, type: :controller do
  describe 'GET #show' do
    it 'renders the :show template' do
      album = create(:album)
      get :show, params: {id: 7, spotify_id: album, user_id: album}
      expect(response).to render_template :show
    end
  end
  describe 'POST #create' do
    it 'assigns the requested show to @tag' do
      # tag = create(:tag)
      # get :create, params: {id: tag}
      # expect(assigns(:album)).to ??? ←どうなればcreateできたことになるのか？
    end
  end
end
