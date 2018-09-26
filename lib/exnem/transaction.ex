defmodule Exnem.Transaction do
  import Exnem,
    only: [
      is_raw: 1,
      is_address: 1,
      is_hex: 1,
      is_base32: 1,
      from_address: 1,
      from_hex: 1,
      from_b32: 1,
      to_hex: 1,
      normalize_address: 1,
      hex_address: 1
    ]

  alias Exnem.Schema.{
    AggregateTransaction,
    Message,
    Mosaic,
    MultisigModification,
    MultisigModifyTransaction,
    MosaicDefinitionTransaction,
    MosaicSupplyChangeTransaction,
    RegisterNamespaceTransaction,
    TransferTransaction
  }

  def transfer(recipient_address, [%Mosaic{} | _] = mosaics, opts \\ [])
      when is_address(recipient_address) do
    recipient = normalize_address(recipient_address)
    message = Keyword.get(opts, :message, "")

    %{
      recipient: from_address(recipient),
      message: %{payload: message},
      mosaics: mosaics |> Enum.map(&Map.from_struct/1),
      deadline: Keyword.get(opts, :deadline, Exnem.deadline())
    }
    |> TransferTransaction.create()
  end

  defp cosigner(public_key, modify_type) do
    %{
      type: MultisigModification.modifyType(modify_type),
      cosignatory_public_key: from_hex(public_key)
    }
  end

  defp add_cosigner(public_key), do: cosigner(public_key, :add)
  defp remove_cosigner(public_key), do: cosigner(public_key, :remove)

  def swap_owner(old_owner_pubkey, new_owner_pubkey, opts \\ [])
      when is_hex(old_owner_pubkey) and is_hex(new_owner_pubkey) do
    %{
      deadline: Keyword.get(opts, :deadline, Exnem.deadline()),
      min_removal_delta: 0,
      min_approval_delta: 0,
      modifications: [
        add_cosigner(new_owner_pubkey),
        remove_cosigner(old_owner_pubkey)
      ]
    }
    |> MultisigModifyTransaction.create()
  end

  # TODO: Should this be renamed/remodeled to be about assigning ownership?
  def bestow(recipient_pubkeys, opts \\ [])
      when is_list(recipient_pubkeys) do
    # FIXME: Default min removal/approval should match the number of recipient pubkeys
    %{
      deadline: Keyword.get(opts, :deadline, Exnem.deadline()),
      min_removal_delta: Keyword.get(opts, :min_removal_delta, 2),
      min_approval_delta: Keyword.get(opts, :min_approval_delta, 2),
      modifications: Enum.map(recipient_pubkeys, &add_cosigner/1)
    }
    |> MultisigModifyTransaction.create()
  end

  def register_root_namespace(name, block_duration, opts \\ [])
      when is_binary(name) and is_integer(block_duration) do
    attrs = %{
      deadline: Keyword.get(opts, :deadline, Exnem.deadline()),
      parentId: 0,
      namespaceName: name,
      namespaceType: Exnem.namespace_type(:root),
      namespaceId: Exnem.namespace_id(name),
      duration: block_duration
    }

    RegisterNamespaceTransaction.create(attrs)
  end

  def register_sub_namespace(parent_namespace, sub_name, opts \\ [])
      when is_binary(parent_namespace) and is_binary(sub_name) do
    attrs = %{
      deadline: Keyword.get(opts, :deadline, Exnem.deadline()),
      parentId: Exnem.namespace_id(parent_namespace),
      namespaceName: sub_name,
      namespaceType: Exnem.namespace_type(:sub),
      namespaceId: Exnem.namespace_id(parent_namespace <> "." <> sub_name)
    }

    RegisterNamespaceTransaction.create(attrs)
  end

  def message(message) when is_binary(message) do
    %{payload: message}
    |> Message.create_plain()
  end

  def mosaic(id, amount) when is_integer(id) and is_integer(amount) do
    %{id: id, amount: amount}
    |> Mosaic.create()
  end

  def mosaic_definition(namespace, name, opts \\ [])
      when is_binary(namespace) and is_binary(name) do
    %{
      parentId: Exnem.namespace_id(namespace),
      mosaicId: Exnem.mosaic_id(namespace <> ":" <> name),
      mosaicName: name,
      duration: Keyword.get(opts, :duration, Exnem.Duration.to_blocks(1, :hour)),
      divisibility: Keyword.get(opts, :divisibility, 0),
      supplyMutable: Keyword.get(opts, :supplyMutable, false),
      transferable: Keyword.get(opts, :transferable, false),
      levyMutable: Keyword.get(opts, :levyMutable, false),
      deadline: Keyword.get(opts, :deadline, Exnem.deadline())
    }
    |> MosaicDefinitionTransaction.create()
  end

  def supply_change(direction, namespace, mosaic, delta, opts \\ [])

  def supply_change(:increase, namespace, mosaic, delta, opts)
      when is_binary(namespace) and is_binary(mosaic) and is_integer(delta) do
    %{
      mosaicId: Exnem.mosaic_id(namespace <> ":" <> mosaic),
      direction: 1,
      delta: delta,
      deadline: Keyword.get(opts, :deadline, Exnem.deadline())
    }
    |> MosaicSupplyChangeTransaction.create()
  end

  def supply_change(:decrease, namespace, mosaic, delta, opts)
      when is_binary(namespace) and is_binary(mosaic) and is_integer(delta) do
    %{
      mosaicId: Exnem.mosaic_id(namespace <> ":" <> mosaic),
      direction: 0,
      delta: delta,
      deadline: Keyword.get(opts, :deadline, Exnem.deadline())
    }
    |> MosaicSupplyChangeTransaction.create()
  end

  def aggregate(inner_transaction, opts \\ [])

  def aggregate(<<_::binary>> = inner_transaction, opts) do
    aggregate([inner_transaction], opts)
  end

  def aggregate([<<_::binary>> | _] = inner_transactions, opts) do
    %{
      transactions_size: length(inner_transactions),
      transactions: inner_transactions,
      deadline: Keyword.get(opts, :deadline, Exnem.deadline())
    }
    |> AggregateTransaction.create()
  end

  def aggregate_partial(_packed_inner_transactions) do
    nil
  end

  def convert_to_inner(%_{} = transaction, public_key) when is_raw(public_key) do
    payload = transaction |> pack()
    sss_size = 4 + 64 + 32

    <<
      _size_signature_signer::bytes-size(sss_size),
      version_type::bytes-size(4),
      _fee_deadline::bytes-size(16),
      rest::binary
    >> = payload

    new_payload = public_key <> version_type <> rest

    <<
      byte_size(new_payload) + 4::little-unsigned-integer-32,
      new_payload::binary
    >>
  end

  def convert_to_inner(%_{} = transaction, address) when is_address(address) do
    convert_to_inner(transaction, from_address(address))
  end

  def convert_to_inner(%_{} = transaction, public_key) when is_base32(public_key) do
    convert_to_inner(transaction, from_b32(public_key))
  end

  def convert_to_inner(%_{} = transaction, public_key) when is_hex(public_key) do
    convert_to_inner(transaction, from_hex(public_key))
  end

  def pack(%RegisterNamespaceTransaction{} = tx) do
    RegisterNamespaceTransaction.pack(tx)
  end

  def pack(%MosaicDefinitionTransaction{} = tx) do
    MosaicDefinitionTransaction.pack(tx)
  end

  def pack(%MosaicSupplyChangeTransaction{} = tx) do
    MosaicSupplyChangeTransaction.pack(tx)
  end

  def pack(%TransferTransaction{} = tx) do
    TransferTransaction.pack(tx)
  end

  def pack(%MultisigModifyTransaction{} = tx) do
    MultisigModifyTransaction.pack(tx)
  end

  def pack(%AggregateTransaction{} = tx) do
    AggregateTransaction.pack(tx)
  end

  def signature_from_payload(hex_payload) when is_binary(hex_payload) do
    <<_::bytes-size(4), signature::bytes-size(64), _::binary>> = from_hex(hex_payload)

    to_hex(signature)
  end

  def signer_from_payload(hex_payload) when is_binary(hex_payload) do
    <<_::bytes-size(68), signer::bytes-size(32), _::binary>> = from_hex(hex_payload)

    to_hex(signer)
  end

  def confirmed?(%{meta: %{merkleComponentHash: merkleComponentHash, hash: hash}}) do
    merkleComponentHash == hash
  end

  def recipient_equals?(%{transaction: %{recipient: recipient}}, %{address: address}) do
    recipient == hex_address(address)
  end

  def transfers_one_mosaic?(%{transaction: %{mosaics: mosaics}}, mosaic_id) do
    mosaics == [%Exnem.DTO.Mosaic{amount: 1, id: mosaic_id}]
  end
end
