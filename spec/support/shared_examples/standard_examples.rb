# frozen_string_literal: true

RSpec.shared_examples 'index examples' do |parent_id:|
end

RSpec.shared_examples 'show examples' do |klass:, resource:|
  it "assigns the requested #{resource} as @#{resource}" do
    object = klass.create! valid_attributes
    get :show, params: empty_params.merge(id: object.to_param)
    expect(assigns(resource)).to eq(object)
  end
end

RSpec.shared_examples 'new examples' do |klass:, resource:|
  it "assigns a new #{resource} as @#{resource}" do
    get :new, params: empty_params
    expect(assigns(resource)).to be_a_new(klass)
  end
end

RSpec.shared_examples 'edit examples' do |klass:, resource:|
  it "assigns the requested #{resource} as @#{resource}" do
    object = klass.create! valid_attributes.merge(user:)
    get :edit, params: empty_params.merge(id: object.to_param)
    expect(assigns(resource)).to eq(object)
  end
end

RSpec.shared_examples 'create examples' do |klass:, resource:|
  context 'with valid attributes' do
    it "creates a new #{klass}" do
      expect do
        post :create, params: empty_params.merge(resource => valid_attributes)
      end.to change(klass, :count).by(1)
    end

    it "assigns a newly created #{resource} as @#{resource}" do
      post :create, params: empty_params.merge(resource => valid_attributes)
      expect(assigns(resource)).to be_a(klass)
    end

    it "persists as @#{resource}" do
      post :create, params: empty_params.merge(resource => valid_attributes)
      expect(assigns(resource)).to be_persisted
    end
  end

  context 'with invalid params' do
    it "assigns a newly created but unsaved #{resource} as @#{resource}" do
      post :create, params: empty_params.merge(resource => invalid_attributes)
      expect(assigns(resource)).to be_a_new(klass)
    end

    it "re-renders the 'new' template" do
      post :create, params: empty_params.merge(resource => invalid_attributes)
      expect(response).to render_template('new')
    end
  end
end

RSpec.shared_examples 'create_and_redirect_example' do |resource:, redirect:|
  context 'with valid attributes' do
    it "redirects to the created #{resource}" do
      post :create, params: empty_params.merge(resource => valid_attributes)
      expect(response).to redirect_to(redirect)
    end
  end
end

RSpec.shared_examples 'update examples' do |klass:, resource:|
  context 'with valid params' do
    it "assigns the requested #{resource} as @#{resource}" do
      object = klass.create! valid_attributes.merge(user:)
      put :update, params: empty_params.merge(:id => object.to_param, resource => valid_attributes)
      expect(assigns(resource)).to eq(object)
    end
  end

  context 'with invalid params' do
    it "assigns the #{resource} as @#{resource}" do
      object = klass.create! valid_attributes.merge(user:)
      put :update, params: empty_params.merge(:id => object.to_param, resource => invalid_attributes)
      expect(assigns(resource)).to eq(object)
    end

    it "re-renders the 'edit' template" do
      object = klass.create! valid_attributes.merge(user:)
      put :update, params: empty_params.merge(:id => object.to_param, resource => invalid_attributes)
      expect(response).to render_template('edit')
    end
  end
end

RSpec.shared_examples 'destroy examples' do |klass:, resource:|
  it "destroys the requested #{resource}" do
    object = klass.create! valid_attributes.merge(user:)
    expect do
      delete :destroy, params: empty_params.merge(id: object.to_param)
    end.to change(klass, :count).by(-1)
  end
end
