## Notification

HassKit support notification send directly from Home Assistant. To enable this feature, please follow these 3 easy steps

## 1. Setup a custom component

Create a folder name notify_hasskit inside Home Assistant folder in the following file structure:
```yaml
.homeassistant/
|-- custom_components/
|   |-- notify_hasskit/
|       |-- __init__.py
|       |-- manifest.json
|       |-- services.yaml
```
[Download](https://github.com/tuanha2000vn/hasskit/raw/master/custom_components/notify_hasskit.zip)
## 2. Edit .homeassistant/configuration.yaml
![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/notification_token.png "Notification Token Guide")

Replace the 'Notification Token Copy From Device 1' with the Notification Token Code in your phone:
```yaml
notify_hasskit:
  token:
    - 'Notification Token Copy From Device 1'
    - 'Notification Token Copy From Device 2'
    - 'Notification Token Copy From Device 3'
```
## 3. Edit .homeassistant/automations.yaml
![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/Notification/image.png "Notification iOS")
![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/Notification/Screenshot_20200105-102626.png "Notification Android")

This sample Home Assistant Automation will send a notification to your phone when the light turned on (replace light.light_1 with your light entity Id):
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
![alt text](https://github.com/tuanha2000vn/hasskit/blob/master/graphic%20template/Notification/node_red.png "Notification Node Red")

And this is the sample using Node-Red (Thank side on Discord channel)
