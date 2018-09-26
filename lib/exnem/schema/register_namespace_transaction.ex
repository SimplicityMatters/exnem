defmodule Exnem.Schema.RegisterNamespaceTransaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @current_version 3

  embedded_schema do
    field(:signature, :binary, default: String.pad_leading("", 64, "\0"))
    field(:signer, :binary, default: String.pad_leading("", 32, "\0"))
    field(:version, :integer, default: Exnem.version(@current_version))
    field(:type, :integer, default: Exnem.transaction_type(:register_namespace))
    field(:fee, :integer, default: 0)
    field(:deadline, :integer)
    field(:duration, :integer)
    field(:parentId, :integer)
    field(:namespaceType, :integer)
    field(:namespaceId, :integer)
    field(:namespaceName, :string)

    # Computed fields
    field(:durationParentId, :integer)
    field(:size, :integer)
    field(:namespaceNameSize, :integer)
  end

  @fields [
    :deadline,
    :duration,
    :parentId,
    :namespaceType,
    :namespaceId,
    :namespaceName
  ]

  @required [
    :version,
    :type,
    :fee,
    :deadline,
    :namespaceType,
    :namespaceId,
    :namespaceName
  ]

  def changeset(struct, attrs \\ %{}) do
    changeset =
      struct
      |> cast(attrs, @fields)
      |> validate_required(@required)
      |> put_change(:namespaceNameSize, byte_size(attrs.namespaceName))
      |> put_change(:size, 138 + byte_size(attrs.namespaceName))

    if changeset.data.namespaceType == Exnem.namespace_type(:sub) do
      changeset
      |> validate_required(:parentId)
    else
      changeset
      |> validate_required(:duration)
    end

    if changeset.valid? do
      duration_parent_id =
        if changeset.changes.namespaceType == Exnem.namespace_type(:sub) do
          changeset.changes.parentId
        else
          changeset.changes.duration
        end

      put_change(changeset, :durationParentId, duration_parent_id)
    else
      changeset
    end
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Ecto.Changeset.apply_action(:insert)
  end

  def pack(%__MODULE__{} = schema) do
    <<
      schema.size::little-unsigned-integer-32,
      schema.signature::bytes-size(64),
      schema.signer::bytes-size(32),
      schema.version::little-unsigned-integer-16,
      schema.type::little-unsigned-integer-16,
      schema.fee::little-unsigned-integer-64,
      schema.deadline::little-unsigned-integer-64,
      schema.namespaceType::little-unsigned-integer-8,
      schema.durationParentId::little-unsigned-integer-64,
      schema.namespaceId::little-unsigned-integer-64,
      schema.namespaceNameSize::little-unsigned-integer-8,
      schema.namespaceName::binary
    >>
  end
end
