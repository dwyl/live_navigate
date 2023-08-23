import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :live_nav, LiveNavWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "dJs53jtdbFYT5TeKAQPVCAsfsSJA1X1LZ6E+e6+uSI3yoa8Xgf5dMALbSYL+NSKd",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
