defmodule Exnem.NamespaceTest do
  use Exnem.Case
  @moduletag :external

  alias Exnem.Namespace

  import Exnem, only: [namespace_id: 1]
  import Exnem.Transaction, only: [register_root_namespace: 2, pack: 1]
  import Exnem.Crypto.KeyPair, only: [sign: 2]
  import Exnem.Announce, only: [sync_announce: 1]

  setup_all [:register_test_namespace]

  describe "id_exists?(namespace_id)" do
    test "it should return false when the namespace does not exist" do
      assert Namespace.id_exists?("ABC123") == false
    end

    test "it should return true when the namespace exists", %{namespace_id: namespace_id} do
      assert Namespace.id_exists?(namespace_id) == true
    end
  end

  describe "name_exists?(namespace_name)" do
    test "it should return false when namespace_name does not exist" do
      assert Namespace.name_exists?("ABC123") == false
    end

    test "it should return true when namespace_name exists", %{namespace_name: namespace_name} do
      assert Namespace.name_exists?(namespace_name) == true
    end
  end

  def register_test_namespace(%{test_keypair: test_keypair}) do
    name = Faker.Lorem.word() <> Faker.Lorem.word()
    duration = Exnem.Duration.to_blocks(1, :minute)

    {:ok, tx} = register_root_namespace(name, duration)

    payload =
      tx
      |> pack()
      |> sign(test_keypair)

    with {:ok, _confirmation} <- sync_announce(payload) do
      {:ok, %{namespace_name: name, namespace_id: namespace_id(name)}}
    end
  end
end
