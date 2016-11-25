package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'
URL = require('socket.url')
JSON = require('dkjson')
redis = (loadfile "./redis.lua")()
redis2 = (loadfile "./redis2.lua")()
HTTPS = require('ssl.https')
redis:auth('CWR_REDIS')
----config----
local bot_api_key = "242799074:AAGvKKomuhL0BdhW2t_G7gbZ01tAL74-VqM"
local BASE_URL = "https://api.pwrtelegram.xyz/bot"..bot_api_key
-------

----utilites----
function is_admin(msg)-- Check if user is admin or not
  local var = false
  local admins = {122774063}
  for k,v in pairs(admins) do
    if msg.from.id == v then
      var = true
    end
  end
  return var
end

function sendRequest(url)
  local dat, res = HTTPS.request(url)
  local tab = JSON.decode(dat)

  if res ~= 200 then
    return false, res
  end

  if not tab.ok then
    return false, tab.description
  end

  return tab

end

function getMe()--https://core.telegram.org/bots/api#getfile
    local url = BASE_URL .. '/getMe'
  return sendRequest(url)
end

function getUpdates(offset)--https://core.telegram.org/bots/api#getupdates

  local url = BASE_URL .. '/getUpdates?timeout=20'

  if offset then

    url = url .. '&offset=' .. offset

  end

  return sendRequest(url)

end

function sendMessage(chat_id, text, disable_web_page_preview, reply_to_message_id, use_markdown)--https://core.telegram.org/bots/api#sendmessage

	local url = BASE_URL .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. URL.escape(text)

	if disable_web_page_preview == true then
		url = url .. '&disable_web_page_preview=true'
	end

	if reply_to_message_id then
		url = url .. '&reply_to_message_id=' .. reply_to_message_id
	end

	if use_markdown then
		url = url .. '&parse_mode=Markdown'
	end

	return sendRequest(url)

end
function sendDocument(chat_id, document, reply_to_message_id)--https://github.com/topkecleon/otouto/blob/master/bindings.lua

	local url = BASE_URL .. '/sendDocument'

	local curl_command = 'cd \''..BASE_FOLDER..currect_folder..'\' && curl -s "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "document=@' .. document .. '"'

	if reply_to_message_id then
		curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
	end
	io.popen(curl_command):read("*all")
	return

end
function download_to_file(url, file_name, file_path)--https://github.com/yagop/telegram-bot/blob/master/bot/utils.lua
  print("url to download: "..url)

  local respbody = {}
  local options = {
    url = url,
    sink = ltn12.sink.table(respbody),
    redirect = true
  }
  -- nil, code, headers, status
  local response = nil
    options.redirect = false
    response = {HTTPS.request(options)}
  local code = response[2]
  local headers = response[3]
  local status = response[4]
  if code ~= 200 then return nil end
  local file_path = BASE_FOLDER..currect_folder..file_name

  print("Saved to: "..file_path)

  file = io.open(file_path, "w+")
  file:write(table.concat(respbody))
  file:close()
  return file_path
end
--------

function bot_run()
	bot = nil

	while not bot do -- Get bot info
		bot = getMe()
	end

	bot = bot.result

	local bot_info = "\27[36mCWR Is Running!\27[39m\nCWR's Username : @"..bot.username.."\nCWR's Name : "..bot.first_name.."\nCWR's ID : "..bot.id.." \n\27[36mBot Developed by iTeam\27[39m\n---------------"

	print(bot_info)

	last_update = last_update or 0

	is_running = true

end

function msg_processor(msg)
local print_text = "\27[36mChat : "..msg.chat.id..", User : "..msg.from.id.."\27[39m\nText : "..(msg.text or "").."\n---------------"
print(print_text)
if msg.date < os.time() - 5 then -- Ignore old msgs
	print("\27[36m(Old Message)\27[39m\n---------------")
	return
end
if msg.text == '/start' or msg.text == '/start@CW_Robot' then
	local text = [[
`سلام من چَتِر بوت 😇  هستم.`

_من هوش مصنوعی دارم 😅 و هرچی‌ تو بگی‌ رو میفهمم و جواب میدم_

*من حدود ۲۰ میلیون کلمه فارسی 🙈 بلدم و میتونم باهاشون باهات حرف بزنم*

اگه میخوای میتونی‌ باهام حرف 😋 بزنی‌!
من تو خصوصی به همه پیامات جواب میدم ولی تو گروها باید روی پیام هایی که من ارسال میکنم ریپلای کنی تا جوابتو بدم :)

قدرت گرفته از [iTeam](https://telegram.me/iTeam_ir)
	]]
	redis2:sadd("CW:users",msg.chat.id)
	sendMessage(msg.chat.id, text, false, msg.message_id, true)
elseif msg.text and msg.text:match("(.*)!!(.*)") then
	local matches = {msg.text:match("(.*)!!(.*)")}
	if matches[2]:match("(telegram.%s)") or matches[2]:match("@") or matches[2]:match("tlgrm.me") or matches[2]:match("https?://([%w-_%.%?%.:/%+=&]+)") and not is_admin(msg) then
		local text = "اضافه کردن لینک و آیدی به عنوان جواب کار دستی نیست دوسته گل\nاین ربات قرار نیست برا شما تبلیغ کنه 😉"
		sendMessage(msg.chat.id, text, false, msg.message_id, true)
	else
		redis:sadd(matches[1],matches[2])
		local text = "خیلی ممنون که بهم کلمه جدید یاد دادی 😇😍 \n\n حالا بلد شدم اگه بگی 😁  \n"..matches[1].."\n 😋 من جواب بدم \n"..matches[2]
		sendMessage(msg.chat.id, text, false, msg.message_id, true)
	end
elseif msg.text == "/teachme" or msg.text == "/teachme@CW_Robot" then
	local text = [[اگه بخوای کلمه یا جمله جدید یادم بدی
 😇 باید دو قسمت مسیج یعنی اون چیزی که تو میخوای بفرستی و اون چیزی که میخوای من جواب بدم رو پشت سر هم تو یک مسیج واسم بفرستی و با دو ! پشت سر هم از هم جداشون کنی 
  

مثل این 😊 
 
سلام،خوبی؟!!مرسی،ممنونم
  
یا 😋 
  
چه خبر؟!!هیچی، تو چه خبر؟
  
یا 😁 
  
Miay berim biroon?!!Are, key berim? 
  
ممنون از اینکه بهم چیزای جدید یاد میدی]]
	sendMessage(msg.chat.id, text, false, msg.message_id, true)
elseif msg.text == "/stats" and is_admin(msg) then
	local words = 0
	local answers = 0
	local allwords = redis:keys("*")
	for i=1,#allwords do
		local hash = allwords[i]
		words = words + 1
		answers = answers + redis:scard(hash)
	end
	local text = "*Users* : `"..redis2:scard("CW:users").."`\n*Total Saved Words* : `"..words.."`\n*Total Saved Answers* : `"..answers.."`"
	sendMessage(msg.chat.id, text, false, msg.message_id, true)
elseif msg.text == "/cleanads" and is_admin(msg) then
	local allwords = redis:keys("*")
	for i=1,#allwords do
		local hash = allwords[i]
		local answers = redis:smembers(hash)
		for i=1,#answers do
			if answers[i]:match("telegram.me") or answers[i]:match("@") then
				redis:srem(hash,answers[i])
			end
		end
	end
	local text = "*All Links And Usernames Cleaned From Bot Answers*"
	sendMessage(msg.chat.id, text, false, msg.message_id, true)
elseif msg.text:match("^/del") and is_admin(msg) then
	if msg.text:match("^/del (.*)^(.*)$") then
		local matches = {msg.text:match("^/del (.*)^(.*)$")}
		redis:srem(matches[1],matches[2])
		local text = matches[2].." از جواب های "..matches[1].." حذف شد "
		sendMessage(msg.chat.id, text, false, msg.message_id, true)
	else
		local matches = {msg.text:match("^/del (.*)$")}
		redis:del(matches[1])
		local text = " تمامی جواب های مربوط به "..matches[1].." حذف شد "
		sendMessage(msg.chat.id, text, false, msg.message_id, true)
	end
else
	if msg.chat.type == "private" or msg.chat.type ~= "private" and msg.reply_to_message and msg.reply_to_message.from.id == 242799074 then
		local answers = redis:smembers(msg.text)
		if #answers == 0 then
			local text = [[من اینو بلد نیستم 😋. اما اگه میخوای اینو  /teachme  کلیک کن تا بتونی یادم بدی]]
			sendMessage(msg.chat.id, text, false, msg.message_id, true)
		else
			local text = answers[math.random(#answers)]
			sendMessage(msg.chat.id, text, false, msg.message_id, true)
		end
	end
end
end

bot_run() -- Run main function
while is_running do -- Start a loop witch receive messages.
	local response = getUpdates(last_update+1) -- Get the latest updates using getUpdates method
	if response then
		for i,v in ipairs(response.result) do
			last_update = v.update_id
			if v.message then
				msg_processor(v.message)
			end
		end
	else
		print("Conection failed")
	end

end
print("Bot halted")
