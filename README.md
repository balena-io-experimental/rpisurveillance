# RaspberryPi Surveillance using [v4l2rtspserver](https://github.com/mpromonet/v4l2rtspserver) with [resin.io](https://resin.io/)

## Getting started

- Sign up on [resin.io](https://dashboard.resin.io/signup).
- Create an application.
- Set the following variables in `Device Configuration` section of the created application:
  - RESIN_HOST_CONFIG_gpu_mem=128
  - RESIN_HOST_CONFIG_start_x=1
- Provision a device which has a camera module attached to the CSI port.
- Clone this repository to a local workspace.
- Add the resin git remote.
- `git push resin master`.

## Configuration

The source code comes with sensible default values for most of the variables but they can be customised using `Environment Variables` per application or per device:

- CAMERA_ROTATE : angle to rotate the camera
- RTSP_PORT : server port
- FRAMERATE : capture framerate
- V4L2_W : capture width
- V4L2_H : capture height

## Testing

You can test using a client like vlc. For example run `vlc` -> Media -> Open Network Stream and play `rtsp://192.168.1.100:8555/unicast`.

## License

Apache 2.0, see [LICENSE](./LICENSE).
