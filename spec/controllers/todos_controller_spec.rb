require 'rails_helper'

RSpec.describe TodosController, type: :controller do
  describe 'GET #index' do
    let!(:todos) { create_list(:todo, 3) }

    it 'returns all todos' do
      get :index
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(3)
      expect(json_response.map { |t| t['title'] }).to match_array(todos.map(&:title))
    end

    it 'filters todos by title' do
      create(:todo, title: 'Special Task One')
      get :index, params: { title: 'Special' }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response.first['title']).to eq('Special Task One')
    end

    it 'filters todos by completed status' do
      create(:todo, completed: true)
      get :index, params: { completed: 'true' }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response.first['completed']).to be true
    end

    it 'filters todos by title and completed status' do
      create(:todo, title: 'Done Task', completed: true)
      create(:todo, title: 'Done Task Two', completed: false)
      get :index, params: { title: 'Done', completed: 'true' }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response.first['title']).to eq('Done Task')
    end
  end

  describe 'GET #show' do
    let!(:todo) { create(:todo) }

    it 'returns the requested todo' do
      get :show, params: { id: todo.id }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(todo.id)
      expect(json_response['title']).to eq(todo.title)
    end

    it 'returns 404 for non-existent todo' do
      get :show, params: { id: 999 }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq({ 'error' => 'Record not found' })
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:valid_params) { { todo: { title: 'New Task', description: 'Do it', completed: false } } }

      it 'creates a new todo' do
        expect {
          post :create, params: valid_params
        }.to change(Todo, :count).by(1)
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['title']).to eq('New Task')
      end
    end

    context 'with invalid attributes' do
      let(:invalid_params) { { todo: { title: '', description: 'Invalid' } } }

      it 'does not create a todo and returns errors' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Todo, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include("Title can't be blank")
      end

      it 'rejects duplicate titles' do
        create(:todo, title: 'Unique Task')
        post :create, params: { todo: { title: 'Unique Task', description: 'Duplicate' } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('Title has already been taken')
      end
    end
  end

  describe 'PUT #update' do
    let!(:todo) { create(:todo) }

    context 'with valid attributes' do
      it 'updates the todo' do
        put :update, params: { id: todo.id, todo: { completed: true } }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['completed']).to be true
        expect(todo.reload.completed).to be true
      end
    end

    context 'with invalid attributes' do
      it 'does not update and returns errors' do
        put :update, params: { id: todo.id, todo: { title: '123' } } # Assuming title_cannot_be_all_numbers validation
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('Title cannot be only numbers')
        expect(todo.reload.title).not_to eq('123')
      end
    end

    it 'returns 404 for non-existent todo' do
      put :update, params: { id: 999, todo: { completed: true } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    let!(:todo) { create(:todo) }

    it 'deletes the todo' do
      expect {
        delete :destroy, params: { id: todo.id }
      }.to change(Todo, :count).by(-1)
      expect(response).to have_http_status(:no_content)
      expect { Todo.find(todo.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns 404 for non-existent todo' do
      delete :destroy, params: { id: 999 }
      expect(response).to have_http_status(:not_found)
    end
  end
end