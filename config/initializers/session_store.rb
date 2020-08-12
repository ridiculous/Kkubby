Kkubby::Application.config.session_store :cookie_store,
                                         key: 'kkubby_session',
                                         secure: Rails.env.production?,
                                         httponly: true
