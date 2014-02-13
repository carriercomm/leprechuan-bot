####
### leprechuan.net administration bot
### mail lib
###
### Copyright (c) 2013 Andrew Northall
###
### MIT License
### See LICENSE file for details.
#####

require 'net/smtp'
require 'uuid'

class Mail
  def self.send(to_addr, message)
    conf = $config["mail"]
    Net::SMTP.start(conf["server"], conf["port"], 'leprechuan.net', conf["user"], \
                    conf["pass"], :plain) do |smtp|
      smtp.enable_starttls
      smtp.send_message message, 'admin@leprechuan.net',
        to_addr
    end
  end

  def self.send_verify(to_addr, id, code)
    
    msgstr = <<-END_OF_MESSAGE
      From: leprechuan.net bot <admin@leprechuan.net>
      To: #{to_addr}
      Reply-to: admin@leprechuan.net
      Subject: leprechuan.net account verification
      Date: #{Time.now.ctime}
      Message-Id: <#{UUID.generate}@leprechuan.net>

      Someone, hopefully you, requested an account in the 
      http://leprechuan.net IRC channel. 

      If this was you, please send

      !verify #{id} #{code} 

      in the #leprechuan channel or in a private message to the bot. 
      If you need any help, please visit:
      http://leprechuan.net/webchat.html

      Regards,
      leprechuan.net team

			http://leprechuan.net/
    END_OF_MESSAGE
    
    # remove whitespace from above
    msg = msgstr.lines.map { |l| l.strip }.join("\r\n")

    self.send(to_addr, msg)
  end

  def self.request_waiting(to_addr, r)
    msgstr = <<-END_OF_MESSAGE
      From: leprechuan.net bot <admin@leprechuan.net>
      To: #{to_addr}
      Reply-to: admin@leprechuan.net
      Subject: leprechuan.net account request - ##{r.id} for #{r.username}
      Date: #{Time.now.ctime}
      Message-Id: <#{UUID.generate}@leprechuan.net>

      There is a leprechuan.net account waiting to be approved. Details:

      ID: #{r.id}
      Username: #{r.username}
      Source: #{r.source} on #{r.ircnet}
      Server: #{r.server} #{r.port}
      Email: #{r.email}
      Timestamp: #{Time.at(r.ts).ctime}
      Requested server: #{r.reqserver || "not specified"}

      Regards,
      leprechuan.net bot
    END_OF_MESSAGE

    msg = msgstr.lines.map { |l| l.strip }.join("\r\n")

    self.send(to_addr, msg)
  end

  def self.send_approved(to_addr, server, user, pass)
    addr = $config["zncservers"][server]["addr"]
    webpanel = $config["zncservers"][server]["public"]["panel"]
    port = $config["zncservers"][server]["public"]["port"]
    sslport = $config["zncservers"][server]["public"]["sslport"]
    
    msgstr = <<-END_OF_MESSAGE
      From: leprechuan.net bot <admin@leprechuan.net>
      To: #{to_addr}
      Reply-to: admin@leprechuan.net
      Subject: leprechuan.net account approved
      Date: #{Time.now.ctime}
      Message-Id: <#{UUID.generate}@leprechuan.net>
      
      Dear #{user},
      
      Your leprechuan.net account has been approved. Your account details are:
      
      Server: #{addr}
      Server name: #{server}
      Plaintext Port: #{port}
      SSL Port: #{sslport}
      Username: #{user}
      Password: #{pass}
      Web Panel: #{webpanel}
      
      In order to connect to your new account, you will need to connect
      your IRC client to #{addr} on port #{port} (or #{sslport} for SSL) 
      and configure your client to send your leprechuan.net username and password 
      together in the server password field, seperated by a colon,
      like so: 
      
      #{user}:#{pass}
      
      Example (Using XCHAT, open a new server tab and type): 
      /server leprechuan.net 5000 #{user}:#{pass}
      
      If you need a ssh account, please request a account in our channel, you must
      explain the use you will have to your account, standard account includes:

      SSH access
      Email Adress (ipv4 and ipv6)
      irssi, eggdrop, mutt, webserver, php, mysql
      quota 10mb
      10 process max.
      mosh
      bind hosts
      
      if you need any special need, please requested at the irc channel.

      If you need any help, please do not hestitate to join our IRC 
      channel: irc.freenode.net #leprechuan - or connect to our webchat
      at https://leprechuan.net/webchat.html.
      
      Regards,
      leprechuan.net team

			http://leprechuan.net/
    END_OF_MESSAGE
    
    # remove whitespace from above
    msg = msgstr.lines.map { |l| l.strip }.join("\r\n")

    self.send(to_addr, msg)
  end
      
end
