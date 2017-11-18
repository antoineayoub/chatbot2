class MessengerBotController < ActionController::Base
  #skip_before_action :authenticate_user!
  #skip_before_action :verify_authenticity_token

  def message(event, sender)
    image_url = 'https://cdn-images-1.medium.com/max/2000/1*RD1s9xBIvd_ycJUnX12Tyw@2x.png'

    sender_id = event["sender"]["id"].to_i
    first_name = sender.get_profile[:body]["first_name"]
    last_name = sender.get_profile[:body]["last_name"]

    profile_pic = sender.get_profile[:body]["profile_pic"]
    msg = event["message"]["text"]

    # profile = sender.get_profile(field) # default field [:locale, :timezone, :gender, :first_name, :last_name, :profile_pic]
    #sender.reply({ text: "#{sender.get_profile[:body]["first_name"]}: #{event['message']['text']}" })

    # generic template
    #generic = GenericTemplate.new(true,'square')

    #btn_1 = Button.new
    #btn_1.add_web_url('Btn 1','www.google.fr')
    #btn_2 = Button.new
    #btn_2.add_web_url('Btn 2', 'www.google.fr')
    #btn_3 = Button.new
    #btn_3.add_web_url('Btn 3', 'www.google.fr')

    #generic.add_element('CHATBOT TUTO', '', image_url, 'Awesome', [btn_1.get_message, btn_2.get_message, btn_3.get_message])

    #sender.reply(generic.get_message)

    # quick_reply.rb
    quickreply = QuickReplyTemplate.new("Do you like Poutine ?")

    quickreply.add_postback('Oui', 'callback_yes')
    quickreply.add_postback('Non', 'callback_no')

    sender.reply(quickreply.get_message)

  end

  def delivery(event, sender)
  end

  def optin(event, sender)
    message_json = {
                  "text": "♥️ from Antoine"
                }
    SendRequest.send(message_json,sender.sender_id_id)
  end

  def postback(event, sender)
    payload = event["postback"]["payload"]

    if payload == 'callback_yes'
      sender.reply({text: "Oh yesss !"})
    elsif payload == 'callback_no'
      sender.reply({text: "Oh noooooo !"})
    end

    #case payload
    #when :something
      #ex: process sender.reply({text: "button click event!"})
    #end
  end

  private

  def find_or_create_user(first_name, last_name, sender_id)
    if User.find_by(facebook_id: sender_id)
      User.find_by(facebook_id: sender_id)
    else
      User.create(email: "#{sender_id}@fakeemail.com",first_name: first_name, last_name: last_name,password: sender_id,facebook_id: sender_id)
    end
  end
end
