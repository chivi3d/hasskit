## HassKit Mobile App Guide

![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_6.png)
![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_4.png)

The new version bring a deeper integration into Home Assistant. You can now register #HassKit as a Mobile App and allow sending notification and update location directly into Home Assistant. Now additional custom component required.

To enable this feature, please follow these 3 easy steps

## 1. Register Mobile App

![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_1.png)
Click Register to regist HassKit as an Home Assistant's Mobile App

![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/mobile_app/Screenshot_2.png)
Then Restart Home Assistant

## 2. Add Notify HassKit to Congifuration

![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/Notification/token.png "Notification Token Guide")

Click Share button and send yourself the token and add them to **.homeassistant/configuration.yaml**. Replace the "Notification Token Copy From Device 1" with the Notification Token Code in your phone:
```yaml
notify_hasskit:
  token:
    - "Notification Token Copy From Device 1"
    - "Notification Token Copy From Device 2"
    - "Notification Token Copy From Device 3"
```
## 3. Create a simple Automation

Open .homeassistant/automations.yaml and add the following lines. This will send a notification to your phone when the light turned on (replace light.light_1 with your light entity Id):
```yaml
- alias: HassKit Test Notification
  trigger:
    - entity_id: light.light_1
      platform: state
      to: "on"
  action:
    - service: notify_hasskit.send
      data:
        device_index: 1
        title: "Light 1"
        body: "Turned On"
```

**Restart Home Assistant**

Use Developer Tools to send test notification:
![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/Notification/developer_tools.png "Notification Developer Tools")

For people use Node-Red instead of Home Assistant automation:
![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/Notification/node_red.png "Notification Node Red")

And this is the sample using Node-Red (Thank side on Discord channel)
