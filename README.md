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
