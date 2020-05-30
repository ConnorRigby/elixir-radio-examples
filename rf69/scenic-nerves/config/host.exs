use Mix.Config

config :radio, :viewport, %{
  name: :main_viewport,
  # default_scene: {Radio.Scene.Crosshair, nil},
  default_scene: {Radio.Scene.SysInfo, [encrypt_key: "sampleEncryptKey"]},
  size: {800, 480},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      opts: [title: "MIX_TARGET=host, app = :radio"]
    }
  ]
}
