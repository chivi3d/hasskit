""" @exlab247@gmail.com
Notification component using Firebase Cloud Messaging
Version 1.0 04 Jan 2020
Give Dust Hoof (^_^)

# [your_config]/custom_components/notify_hasskit
.homeassistant/
|-- custom_components/
|   |-- notify_hasskit/
|       |-- __init__.py
|       |-- manifest.json
|       |-- services.yaml

# Config in configuration.yaml file for Home Assistant
notify_hasskit:
  token:
    - 'abc_token_device_1'
    - 'abc_token_device_2'
    - 'abc_token_device_n'

# Code in script
notify_msg:
  sequence:
    - service: notify_hasskit.send
      data:
        device_index: 1 # for abc_token_device_1
        title: Tiêu đề thông báo
        body: Đây là nội dung thông báo.
"""

# declare variables
DOMAIN = 'notify_hasskit'
SERVICE_SEND = 'send'
FCM_TOKEN = 'token'

# data message
CONF_DEVICE_INDEX = 'device_index' # start = 1
CONF_TITLE = 'title'
CONF_BODY= 'body'

# const data
url = "https://fcm.googleapis.com/fcm/send"
api_key = "key=AAAA7WhBA9E:APA91bGxg52oNvwKsq50pcWa-k4JGZMkXvO11m3QP0rnEVSS7D4qhEubqWBsgmVN-b4PqwsHLs3xOKXEi1qD5Nr_dsVd6NUW9VDQqaaS6hCm2pE-u5IOltOuEOkKjDpfZPPAmXzkB4DI"
header_parameters = {'Authorization': api_key, 'content-type': 'application/json',}

import requests
def send_msg(token_, title_, body_):
    data_msg = {"to": token_, "collapse_key": "type_a", "notification": {"body": body_, "title": title_}}
    status_response = requests.post(url, json = data_msg, headers = header_parameters).status_code
    if (status_response != 200): # try again
        requests.post(url, json = data_msg, headers = header_parameters)

def setup(hass, config):

    def call_send_msg(data_call):
        # get fcm_token
        list_token = config[DOMAIN][FCM_TOKEN]
        # get data msg
        index  = int(data_call.data.get(CONF_DEVICE_INDEX, 1))
        title  = str(data_call.data.get(CONF_TITLE, "Title of notification"))
        body  = str(data_call.data.get(CONF_BODY, "Body of notification"))
        index = max(1, min(index, len(list_token))) - 1
        token = list_token[index]
        # send msg
        send_msg(token, title, body)
        
    hass.services.register(DOMAIN, SERVICE_SEND, call_send_msg)
    return True
