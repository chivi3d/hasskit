## Notification

HassKit support notification send directly from Home Assistant. To enable this feature, please follow these 3 easy steps

## 1 Setup a custom component

Create a folder name notify_hasskit inside Home Assistant folder in the following file structure:
```yaml
.homeassistant/
|-- custom_components/
|   |-- notify_hasskit/
|       |-- __init__.py
|       |-- manifest.json
|       |-- services.yaml
```
[Download](https://github.com/tuanha2000vn/hasskit/tree/master/custom_components/notify_hasskit)
## 2 Edit .homeassistant/configuration.yaml

Add the following line:
```yaml
notify_hasskit:
  token:
    - 'Notification Token of Device 1'
    - 'Notification Token of Device 2'
    - 'Notification Token of Device 3'
```
## 3 Edit .homeassistant/automations.yaml
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
