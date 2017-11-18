## **Launch the project**

Create Rails project

    $ rails new project_name
    $ cd project_name
    $ stt
    $ rails db:create db:migrate

Add the gem 'messenger-bot' but the MatthiasRMS version

    gem 'messenger-bot', :git => 'git://github.com/MatthiasRMS/messenger-bot-rails'
    
    $ bundle install

 **Facebook Configuration** 

- Create a FaceBook page

 [https://www.facebook.com/pages/create/](https://www.facebook.com/pages/create/) 

- Create a FaceBook app :

 [https://developers.facebook.com/](https://developers.facebook.com/) 

- Add a Messenger Product to your App
- Messenger / Settings : Generate a Token by selecting your page on the dropdown

![](https://static.notion-static.com/4d0b0b7683d14853aa6f3aaae5a1037b/Screen_Shot_2017-11-18_at_02.35.11.png)

- Report the credentials in the `application.yml` : Page Token and App Secret Key

    development:
    FB_PAGE_KEY: 'EAAB2lF1nr5ABAIZCIU.....etw8IqCqzh2kPDCJAu'
    FB_SECRET_PASS: '8337f0cd.....192c45c'
    
    staging:
    FB_PAGE_KEY: 'EAAB2lF1nr5ABAIZCIU.....etw8IqCqzh2kPDCJAu'
    FB_SECRET_PASS: '8337f0cd.....192c45c'
    
    production:
    FB_PAGE_KEY: 'EAAB2lF1nr5ABAIZCIU.....etw8IqCqzh2kPDCJAu'
    FB_SECRET_PASS: '8337f0cd.....192c45c'
    

 **LET'S CODE THE BACKEND** 

- Create a `messenger_bot.rb` in the initializers
- Configure the initializer :

    Messenger::Bot.config do |config|
    	config.access_token = ENV['FB_PAGE_KEY']
    	config.validation_token = ENV['FB_PAGE_KEY']
    	config.secret_token = ENV['FB_SECRET_PASS']
    end

- Add those routes :

    mount Messenger::Bot::Space => "/webhook"

- Create a new controller `MessengerBotController` :

    class MessengerBotController < ActionController::Base
    
    	def message(event, sender)
    		 # profile = sender.get_profile(field) # default field [:locale, :timezone, :gender, :first_name, :last_name, :profile_pic]
     sender.reply({ text: "Reply: #{event['message']['text']}" })
     end
    
     def delivery(event, sender)
     end
    	
    	def optin(event, sender)
     end
    
     def postback(event, sender)
     payload = event["postback"]["payload"]
     case payload
     when :something
     #ex: process sender.reply({text: "button click event!"})
     end
     end
    end

 [https://developers.facebook.com/docs/messenger-platform/webhook#subscribe](https://developers.facebook.com/docs/messenger-platform/webhook#subscribe) 

- NB : if you are using devise you need to skip the authentication for this controller :

    class MessengerBotController < ActionController::Base
    	skip_before_action :authenticate_user!
    	skip_before_action :verify_authenticity_token
    	....
    end

## **How to test the chatbot ?**

We need a server running not locally but accessible on the web

 `ngrok` will help us to expose our localhost on the web

https://ngrok.com/

Save the `ngrok` file in the same folder as your app and launch it with the commande : `../ngrok http 3000` 

then run your server : `rails s` 

 _NB: if you make changes on your code never stop the ngrok tunnel but relaunch your server_ 

 **What we received from messenger ?** 

Event : json informations about the event 

Sender : informations about the sender (use `sender.get_profile` to have the details)

    sender_id = event["sender"]["id"].to_i
    first_name = sender.get_profile[:body]["first_name"]
    last_name = sender.get_profile[:body]["last_name"]
    name = (first_name + last_name).downcase
    
    profile_pic = sender.get_profile[:body]["profile_pic"]
    msg = event["message"]["text"]

## **Some usefull function to add in the controller**

 **Find or Create a user** 

each time your backend receive a message you should find in your database if the user exist to assign the conversation or create the user

    def find_or_create_user(first_name, last_name, sender_id)
    	if User.find_by(facebook_id: sender_id)
    		User.find_by(facebook_id: sender_id)
    	else
    		User.create(email: "#{sender_id}@fake_email.com",first_name: first_name, last_name: last_name,password: sender_id,facebook_id: sender_id)
    	end
    end

 **Find or Create a session** 

each time your backend receive a message you want to create or update the user session (cf session concept bellow)

    def find_or_create_session(user_id)#, max_age: 59.minutes)
    	if Session.find_by("user_id = ?", user_id )# AND last_exchange >= ? ", max_age.ago)
    	 session = Session.find_by("user_id = ?", user_id )# AND last_exchange >= ? ", user_id, max_age.ago)
     session.update(last_exchange: Time.now)
    	 return session
    	else
    	 session = Session.create(context: {}, previous_context: {}, user_id: user_id, last_exchange: Time.now)
    	 return session
    	end
    end

## Let's template things

 [https://developers.facebook.com/docs/messenger-platform/send-messages/templates](https://developers.facebook.com/docs/messenger-platform/send-messages/templates) 

The gem manage several templates :

1. button.rb
2. file.rb
3. generic.rb
4. image.rb
5. list.rb
6. quick_reply.rb
7. receipt.rb
8. text.rb

## Asynchronous system : How to manage that ? creating a Session !

By saving the state in the database

We will create a table Sessions to save the context and the previous context

    rails g migration CreateSessions

5 fields :

    create_table :sessions do |t|
    	t.jsonb :context
    	t.jsonb :previous_context
     t.references :user
     t.datetime :last_exchange
     t.timestamps
     end

    rails db:migrate
