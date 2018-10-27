require 'rails_helper'

describe AlbumsController, type: :controller do
  describe 'GET #show' do
    it 'renders the :show template' do
      get :show, params: {id: 7}
      expect(response).to render_template :show
    end
  end

  describe 'POST #create' do
    it 'assigns the requested show to @tag'
    end
    it 'renders the :create template' do
    end
  end
end
