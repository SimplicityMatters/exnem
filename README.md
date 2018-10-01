# Nem2 SDK for Elixir

A library for working with the NEM2 (Catapult) Blockchain.

** NOTE: This is a work in progress and may change significantly. **

## Features

* KeyPair generation
* Transactions
    * Transfer
    * Multi-sig Modify
    * Mosaic Definition
    * Mosaic Supply Change
    * Register Namespace
    * Aggregate Complete
* Announce Transactions (Sync)
* Announce Transactions (Async)
* WebSocket Connections
* Account Info
* Namespace Info
* Mosaic Info

## Installation

The package can be installed by adding `exnem` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exnem, github: "SimplicityMatters/exnem", branch: "master"}
  ]
end
```

## TODO

* Add examples
* Support HashLock transactions
* Support Announcing partial transactions
* Support Cosignature transactions
* Support SecretLock/Proof transactions
* Complete support for reading from Catapult API

## Contributions

Contributions are welcomed! Open a pull request or issue and we'll happily work to integrate changes and address problems.

License
--

Copyright 2018 He3Labs

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
