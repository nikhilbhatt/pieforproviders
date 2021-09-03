# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  # Do not send any emails (no confirmation emails, no password was changed emails)
  before(:each) do
    allow_any_instance_of(User).to receive(:send_confirmation_notification?).and_return(false)
    allow_any_instance_of(User).to receive(:send_password_change_notification?).and_return(false)
  end

  let!(:logged_in_user) { create(:confirmed_user) }
  let!(:other_user) { create(:confirmed_user) }
  let!(:admin_user) { create(:confirmed_user, admin: true) }

  describe 'GET /api/v1/users' do
    include_context 'correct api version header'

    context 'for non-admin user' do
      before do
        sign_in logged_in_user
      end

      it 'returns only the user' do
        get '/api/v1/users', headers: headers
        expect(response.status).to eq(403)
      end
    end

    context 'for admin user' do
      before do
        sign_in admin_user
      end

      it 'returns all users' do
        get '/api/v1/users', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |x| x['greeting_name'] }).to include(logged_in_user.greeting_name)
        expect(parsed_response.collect { |x| x['greeting_name'] }).to include(other_user.greeting_name)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('users')
      end
    end
  end

  describe 'GET /api/v1/users/:id' do
    include_context 'correct api version header'

    context 'for non-admin user' do
      before do
        sign_in logged_in_user
      end

      it 'returns the user using their ID' do
        get "/api/v1/users/#{logged_in_user.id}", headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['greeting_name']).to eq(logged_in_user.greeting_name)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('user')
      end

      it 'returns the user using /profile' do
        get '/api/v1/profile', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['greeting_name']).to eq(logged_in_user.greeting_name)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('user')
      end

      it 'does not return another user' do
        get "/api/v1/users/#{other_user.id}", headers: headers
        expect(response.status).to eq(404)
      end
    end

    context 'for admin user' do
      before do
        sign_in admin_user
      end

      it 'returns the user' do
        get "/api/v1/users/#{logged_in_user.id}", headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['greeting_name']).to eq(logged_in_user.greeting_name)
        expect(response).to match_response_schema('user')
      end

      it 'returns the admin user using /profile' do
        get '/api/v1/profile', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['greeting_name']).to eq(admin_user.greeting_name)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('user')
      end

      it 'returns the other user' do
        get "/api/v1/users/#{other_user.id}", headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['greeting_name']).to eq(other_user.greeting_name)
        expect(response).to match_response_schema('user')
      end

      # TODO: requires user policy changes
      # it 'returns the other user' do
      #   get "/api/v1/users/#{other_user.id}", headers: headers
      #   parsed_response = JSON.parse(response.body)
      #   expect(parsed_response['greeting_name']).to eq(other_user.greeting_name)
      #   expect(response).to match_response_schema('user')
      # end
    end
  end

  describe 'GET /api/v1/case_list_for_dashboard' do
    include_context 'correct api version header'
    let!(:nebraska_user) { create(:confirmed_user) }
    let!(:nebraska_business) { create(:business, :nebraska, user: nebraska_user) }
    let!(:nebraska_user_children) do
      create_list(:child, 2, {
                    business: nebraska_business,
                    approvals: [
                      create(:expired_approval, create_children: false),
                      create(:approval, create_children: false)
                    ]
                  })
    end
    let!(:illinois_user) { create(:confirmed_user) }
    let!(:illinois_business) { create(:business, user: illinois_user) }
    let!(:illinois_user_children) do
      create_list(:child, 2, {
                    business: illinois_business,
                    approvals: [
                      create(:expired_approval, create_children: false),
                      create(:approval, create_children: false)
                    ]
                  })
    end

    context 'for non-admin user in illinois' do
      before do
        sign_in illinois_user
      end

      it 'returns the correct data schema' do
        get '/api/v1/case_list_for_dashboard', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(2)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('illinois_case_list_for_dashboard')
      end

      it 'returns the correct cases when a filter_date is sent' do
        get '/api/v1/case_list_for_dashboard', params: { filter_date: '2017-12-12' }, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(0)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('illinois_case_list_for_dashboard')
      end
    end

    context 'for non-admin user in nebraska' do
      before do
        sign_in nebraska_user
      end

      it 'returns the correct data schema' do
        get '/api/v1/case_list_for_dashboard', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(2)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
      end

      it 'returns the correct cases when a filter_date is sent' do
        get '/api/v1/case_list_for_dashboard', params: { filter_date: '2017-12-12' }, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(0)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
      end
    end

    context 'for admin user' do
      before do
        sign_in admin_user
      end

      it 'returns the correct data schema' do
        get '/api/v1/case_list_for_dashboard', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(4)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
      end
    end
  end
end
