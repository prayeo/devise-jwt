# devise-jwt for rails server api only

### 1. 프로젝트 생성

```bash
$ rails new devise-jwt --api --database=postgresql

$ cd devise-jwt
```



### 2. devise gem 설치 후 config 설정

gem 파일 추가

```ruby
# Gemfile
...
gem 'devise' # 추가
...
```

gem 설치 후 devise install

```bash
$ bundle install

$ rails generate devise:install
```

default URL options for the Devise mailer in each environment 을 위해

```ruby
# config/environments/development.rb
Rails.application.configure do
  ...
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 } # 추가
  ...
end
```

그리고 User model & table 생성

```bash
$ rails generate devise User

# 실행결과
  invoke  active_record
  create    db/migrate/20180602065912_devise_create_users.rb
  create    app/models/user.rb
  invoke    test_unit
  create      test/models/user_test.rb
  create      test/fixtures/users.yml
  insert    app/models/user.rb
  route  devise_for :users
  
$ rails db:create # db 생성 config/database.yml 수정이 필요할 수도 있다.
$ rails db:migate

# 실행결과
== 20180602065912 DeviseCreateUsers: migrating ================================
-- create_table(:users)
   -> 0.0204s
-- add_index(:users, :email, {:unique=>true})
   -> 0.0052s
-- add_index(:users, :reset_password_token, {:unique=>true})
   -> 0.0031s
== 20180602065912 DeviseCreateUsers: migrated (0.0289s) =======================
```



### 3. Configuring devise for APIs

#### 먼저, Responding to `json` 해주고 

API에 속하지 않은 ActionController::MimeResponds 기능 다시 불러오기

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::API
  include ActionController::MimeResponds # 추가
  respond_to :json # 추가
end
```



#### my_application_sessions controller 생성

```bash
$ rails g controller my_application_sessions
```

devise sessions 을 받아오게끔 수정

```ruby
#class MyApplicationSessionsController < ApplicationController =>
class MyApplicationSessionsController < Devise::SessionsController
  def create
    super { |resource| @resource = resource }
  end
end
```

잊지말고 route 도 수정! 

```ruby
# config/routes.rb

Rails.application.routes.draw do
  # devise_for :users =>
  devise_for :users, controllers: { sessions: 'my_application_sessions' }, defaults: { format: :json } # defaults format은 url 끝에 .json을 안붙여도 설정해줌.
end
```



#### View 관련 Validation errors format

responder.rb 이용

```ruby
# app/controllers/concerns/my_application_responder.rb 생성

module MyApplicationResponder
  protected

  def json_resource_errors
    {
      success: false,
      errors: MyApplicationErrorFormatter.call(resource.errors)
    }
  end
end
```

```ruby
# app/controllers/my_application_sessions_controller.rb

class MyApplicationSessionsController < Devise::SessionsController
  responders :my_application # 추가

  def create
    super { |resource| @resource = resource }
  end
end
```

#### Authentication errors format

```ruby
# app/controllers/concerns/my_application_failure_app.rb 생성

class MyApplicationFailureApp < Devise::FailureApp
  def http_auth_body
    return super unless request_format == :json
    {
      sucess: false,
      message: i18n_message
    }.to_json
  end
end
```

```ruby
# config/initializers/devise.rb
Devise.setup do |config|
	...
  config.warden do |manager|
      manager.failure_app = MyApplicationFailureApp
  end
  ...
end
```

