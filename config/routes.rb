# frozen_string_literal: true

is_html_request = ->(request) { !request.xhr? && request.format.html? }

Rails.application.routes.draw do
  # This is required because the `devise_for` call generates a `GET /login`
  # route which we don't want to expose
  get '/login', to: 'static#fallback_index_html', constraints: is_html_request

  devise_for :users,
             path: '',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'signup'
             },
             controllers: {
               sessions: 'sessions',
               registrations: 'registrations',
               confirmations: 'confirmations',
               passwords: 'passwords'
             }
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  scope module: :api, defaults: { format: :json }, path: 'api' do
    scope module: :v1, constraints: ApiConstraint.new(version: 1, default: true), path: 'v1' do
      resources :users, only: %i[index show]
      get 'profile', to: 'users#show'
      resources :businesses
      resources :children
      resources :attendances, only: :index
      resources :attendance_batches, only: :create
      get 'case_list_for_dashboard', to: 'users#case_list_for_dashboard'
    end
  end

  get '*path', to: 'static#fallback_index_html', constraints: is_html_request
end

# rubocop:disable Layout/LineLength

# == Route Map
#
#                                   Prefix Verb   URI Pattern                                                                                       Controller#Action
#                                    login GET    /login(.:format)                                                                                  static#fallback_index_html
#                         new_user_session GET    /login(.:format)                                                                                  sessions#new
#                             user_session POST   /login(.:format)                                                                                  sessions#create
#                     destroy_user_session DELETE /logout(.:format)                                                                                 sessions#destroy
#                        new_user_password GET    /password/new(.:format)                                                                           passwords#new
#                       edit_user_password GET    /password/edit(.:format)                                                                          passwords#edit
#                            user_password PATCH  /password(.:format)                                                                               passwords#update
#                                          PUT    /password(.:format)                                                                               passwords#update
#                                          POST   /password(.:format)                                                                               passwords#create
#                 cancel_user_registration GET    /signup/cancel(.:format)                                                                          registrations#cancel
#                    new_user_registration GET    /signup/sign_up(.:format)                                                                         registrations#new
#                   edit_user_registration GET    /signup/edit(.:format)                                                                            registrations#edit
#                        user_registration PATCH  /signup(.:format)                                                                                 registrations#update
#                                          PUT    /signup(.:format)                                                                                 registrations#update
#                                          DELETE /signup(.:format)                                                                                 registrations#destroy
#                                          POST   /signup(.:format)                                                                                 registrations#create
#                    new_user_confirmation GET    /confirmation/new(.:format)                                                                       confirmations#new
#                        user_confirmation GET    /confirmation(.:format)                                                                           confirmations#show
#                                          POST   /confirmation(.:format)                                                                           confirmations#create
#                        letter_opener_web        /letter_opener                                                                                    LetterOpenerWeb::Engine
#                                    users GET    /api/v1/users(.:format)                                                                           api/v1/users#index {:format=>:json}
#                                     user GET    /api/v1/users/:id(.:format)                                                                       api/v1/users#show {:format=>:json}
#                                  profile GET    /api/v1/profile(.:format)                                                                         api/v1/users#show {:format=>:json}
#                               businesses GET    /api/v1/businesses(.:format)                                                                      api/v1/businesses#index {:format=>:json}
#                                          POST   /api/v1/businesses(.:format)                                                                      api/v1/businesses#create {:format=>:json}
#                                 business GET    /api/v1/businesses/:id(.:format)                                                                  api/v1/businesses#show {:format=>:json}
#                                          PATCH  /api/v1/businesses/:id(.:format)                                                                  api/v1/businesses#update {:format=>:json}
#                                          PUT    /api/v1/businesses/:id(.:format)                                                                  api/v1/businesses#update {:format=>:json}
#                                          DELETE /api/v1/businesses/:id(.:format)                                                                  api/v1/businesses#destroy {:format=>:json}
#                                 children GET    /api/v1/children(.:format)                                                                        api/v1/children#index {:format=>:json}
#                                          POST   /api/v1/children(.:format)                                                                        api/v1/children#create {:format=>:json}
#                                    child GET    /api/v1/children/:id(.:format)                                                                    api/v1/children#show {:format=>:json}
#                                          PATCH  /api/v1/children/:id(.:format)                                                                    api/v1/children#update {:format=>:json}
#                                          PUT    /api/v1/children/:id(.:format)                                                                    api/v1/children#update {:format=>:json}
#                                          DELETE /api/v1/children/:id(.:format)                                                                    api/v1/children#destroy {:format=>:json}
#                              attendances GET    /api/v1/attendances(.:format)                                                                     api/v1/attendances#index {:format=>:json}
#                       attendance_batches POST   /api/v1/attendance_batches(.:format)                                                              api/v1/attendance_batches#create {:format=>:json}
#                  case_list_for_dashboard GET    /api/v1/case_list_for_dashboard(.:format)                                                         api/v1/users#case_list_for_dashboard {:format=>:json}
#                                          GET    /*path(.:format)                                                                                  static#fallback_index_html
#            rails_postmark_inbound_emails POST   /rails/action_mailbox/postmark/inbound_emails(.:format)                                           action_mailbox/ingresses/postmark/inbound_emails#create
#               rails_relay_inbound_emails POST   /rails/action_mailbox/relay/inbound_emails(.:format)                                              action_mailbox/ingresses/relay/inbound_emails#create
#            rails_sendgrid_inbound_emails POST   /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                           action_mailbox/ingresses/sendgrid/inbound_emails#create
#      rails_mandrill_inbound_health_check GET    /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#health_check
#            rails_mandrill_inbound_emails POST   /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#create
#             rails_mailgun_inbound_emails POST   /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                                       action_mailbox/ingresses/mailgun/inbound_emails#create
#           rails_conductor_inbound_emails GET    /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#index
#                                          POST   /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#create
#            rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#show
#                                          PATCH  /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#update
#                                          PUT    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#update
#                                          DELETE /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#destroy
# new_rails_conductor_inbound_email_source GET    /rails/conductor/action_mailbox/inbound_emails/sources/new(.:format)                              rails/conductor/action_mailbox/inbound_emails/sources#new
#    rails_conductor_inbound_email_sources POST   /rails/conductor/action_mailbox/inbound_emails/sources(.:format)                                  rails/conductor/action_mailbox/inbound_emails/sources#create
#    rails_conductor_inbound_email_reroute POST   /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                               rails/conductor/action_mailbox/reroutes#create
#                       rails_service_blob GET    /rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)                               active_storage/blobs/redirect#show
#                 rails_service_blob_proxy GET    /rails/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                  active_storage/blobs/proxy#show
#                                          GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                                        active_storage/blobs/redirect#show
#                rails_blob_representation GET    /rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations/redirect#show
#          rails_blob_representation_proxy GET    /rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)    active_storage/representations/proxy#show
#                                          GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)          active_storage/representations/redirect#show
#                       rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                                       active_storage/disk#show
#                update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                               active_storage/disk#update
#                     rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                                    active_storage/direct_uploads#create
#
# Routes for LetterOpenerWeb::Engine:
# clear_letters DELETE /clear(.:format)                 letter_opener_web/letters#clear
# delete_letter DELETE /:id(.:format)                   letter_opener_web/letters#destroy
#       letters GET    /                                letter_opener_web/letters#index
#        letter GET    /:id(/:style)(.:format)          letter_opener_web/letters#show
#               GET    /:id/attachments/:file(.:format) letter_opener_web/letters#attachment
