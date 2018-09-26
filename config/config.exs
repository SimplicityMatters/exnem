# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ed25519,
  hash_fn: {:keccakf1600, :hash, [:sha3_512], []}

config :exnem,
  network_type: :mijin_test,
  node_url: "localhost:3000",
  block_duration: 15 # seconds
