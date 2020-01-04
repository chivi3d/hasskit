## Notification

HassKit support notification send directly from Home Assistant. To enable this feature, please follow these 3 easy steps

## 1 Setup a custom component

Create a folder name notify_hasskit inside Home Assistant folder in the following file structure:

.homeassistant/
|-- custom_components/
|   |-- notify_hasskit/
|       |-- __init__.py
|       |-- manifest.json
|       |-- services.yaml

## 2 Edit .homeassistant/configuration.yaml

Add the following line:

notify_hasskit:
  token:
    - 'device_1_token'
    - 'device_2_token'
    - 'device_3_token'

## 3 Edit .homeassistant/automations.yaml

- alias: HassKit Test
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