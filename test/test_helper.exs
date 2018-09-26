ExUnit.configure(exclude: :external)
ExUnit.start()

defmodule Exnem.Case do
  use ExUnit.CaseTemplate

  setup_all do
    %{
      test_keypair: %{
        public_key: "9a49366406aca952b88badf5f1e9be6ce4968141035a60be503273ea65456b24",
        private_key: "041e2ce90c31cd65620ed16ab7a5a485e5b335d7e61c75cd9b3a2fed3e091728"
      }
    }
  end
end
