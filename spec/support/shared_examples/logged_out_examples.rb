# frozen_string_literal: true

# Rspec.shared_examples
RSpec.shared_examples 'logged out examples' do |klass:, resource:|
  %i[index new].each do |action|
    it "Get #{action}" do
      get action, params: empty_params, session: invalid_session
      expect(response).to redirect_to(root_url)
    end
  end

  %i[show edit].each do |action|
    it "Get #{action}" do
      object = klass.create! valid_attributes
      get action, params: empty_params.merge(id: object.to_param), session: invalid_session
      expect(response).to redirect_to(root_url)
    end
  end

  it 'POST #create' do
    post :create, params: empty_params.merge(resource => valid_attributes), session: invalid_session
    expect(response).to redirect_to(root_url)
  end
end
