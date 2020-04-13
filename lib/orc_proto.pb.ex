defmodule Orc.Proto.EncryptionAlgorithm do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  @type t :: integer | :UNKNOWN_ENCRYPTION | :AES_CTR_128 | :AES_CTR_256

  field :UNKNOWN_ENCRYPTION, 0
  field :AES_CTR_128, 1
  field :AES_CTR_256, 2
end

defmodule Orc.Proto.KeyProviderKind do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  @type t :: integer | :UNKNOWN | :HADOOP | :AWS | :GCP | :AZURE

  field :UNKNOWN, 0
  field :HADOOP, 1
  field :AWS, 2
  field :GCP, 3
  field :AZURE, 4
end

defmodule Orc.Proto.CompressionKind do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  @type t :: integer | :NONE | :ZLIB | :SNAPPY | :LZO | :LZ4 | :ZSTD

  field :NONE, 0
  field :ZLIB, 1
  field :SNAPPY, 2
  field :LZO, 3
  field :LZ4, 4
  field :ZSTD, 5
end

defmodule Orc.Proto.Stream.Kind do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  @type t ::
          integer
          | :PRESENT
          | :DATA
          | :LENGTH
          | :DICTIONARY_DATA
          | :DICTIONARY_COUNT
          | :SECONDARY
          | :ROW_INDEX
          | :BLOOM_FILTER
          | :BLOOM_FILTER_UTF8
          | :ENCRYPTED_INDEX
          | :ENCRYPTED_DATA
          | :STRIPE_STATISTICS
          | :FILE_STATISTICS

  field :PRESENT, 0
  field :DATA, 1
  field :LENGTH, 2
  field :DICTIONARY_DATA, 3
  field :DICTIONARY_COUNT, 4
  field :SECONDARY, 5
  field :ROW_INDEX, 6
  field :BLOOM_FILTER, 7
  field :BLOOM_FILTER_UTF8, 8
  field :ENCRYPTED_INDEX, 9
  field :ENCRYPTED_DATA, 10
  field :STRIPE_STATISTICS, 100
  field :FILE_STATISTICS, 101
end

defmodule Orc.Proto.ColumnEncoding.Kind do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  @type t :: integer | :DIRECT | :DICTIONARY | :DIRECT_V2 | :DICTIONARY_V2

  field :DIRECT, 0
  field :DICTIONARY, 1
  field :DIRECT_V2, 2
  field :DICTIONARY_V2, 3
end

defmodule Orc.Proto.Type.Kind do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  @type t ::
          integer
          | :BOOLEAN
          | :BYTE
          | :SHORT
          | :INT
          | :LONG
          | :FLOAT
          | :DOUBLE
          | :STRING
          | :BINARY
          | :TIMESTAMP
          | :LIST
          | :MAP
          | :STRUCT
          | :UNION
          | :DECIMAL
          | :DATE
          | :VARCHAR
          | :CHAR
          | :TIMESTAMP_INSTANT

  field :BOOLEAN, 0
  field :BYTE, 1
  field :SHORT, 2
  field :INT, 3
  field :LONG, 4
  field :FLOAT, 5
  field :DOUBLE, 6
  field :STRING, 7
  field :BINARY, 8
  field :TIMESTAMP, 9
  field :LIST, 10
  field :MAP, 11
  field :STRUCT, 12
  field :UNION, 13
  field :DECIMAL, 14
  field :DATE, 15
  field :VARCHAR, 16
  field :CHAR, 17
  field :TIMESTAMP_INSTANT, 18
end

defmodule Orc.Proto.IntegerStatistics do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          minimum: integer,
          maximum: integer,
          sum: integer
        }
  defstruct [:minimum, :maximum, :sum]

  field :minimum, 1, optional: true, type: :sint64
  field :maximum, 2, optional: true, type: :sint64
  field :sum, 3, optional: true, type: :sint64
end

defmodule Orc.Proto.DoubleStatistics do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          minimum: float | :infinity | :negative_infinity | :nan,
          maximum: float | :infinity | :negative_infinity | :nan,
          sum: float | :infinity | :negative_infinity | :nan
        }
  defstruct [:minimum, :maximum, :sum]

  field :minimum, 1, optional: true, type: :double
  field :maximum, 2, optional: true, type: :double
  field :sum, 3, optional: true, type: :double
end

defmodule Orc.Proto.StringStatistics do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          minimum: String.t(),
          maximum: String.t(),
          sum: integer,
          lowerBound: String.t(),
          upperBound: String.t()
        }
  defstruct [:minimum, :maximum, :sum, :lowerBound, :upperBound]

  field :minimum, 1, optional: true, type: :string
  field :maximum, 2, optional: true, type: :string
  field :sum, 3, optional: true, type: :sint64
  field :lowerBound, 4, optional: true, type: :string
  field :upperBound, 5, optional: true, type: :string
end

defmodule Orc.Proto.BucketStatistics do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          count: [non_neg_integer]
        }
  defstruct [:count]

  field :count, 1, repeated: true, type: :uint64, packed: true
end

defmodule Orc.Proto.DecimalStatistics do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          minimum: String.t(),
          maximum: String.t(),
          sum: String.t()
        }
  defstruct [:minimum, :maximum, :sum]

  field :minimum, 1, optional: true, type: :string
  field :maximum, 2, optional: true, type: :string
  field :sum, 3, optional: true, type: :string
end

defmodule Orc.Proto.DateStatistics do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          minimum: integer,
          maximum: integer
        }
  defstruct [:minimum, :maximum]

  field :minimum, 1, optional: true, type: :sint32
  field :maximum, 2, optional: true, type: :sint32
end

defmodule Orc.Proto.TimestampStatistics do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          minimum: integer,
          maximum: integer,
          minimumUtc: integer,
          maximumUtc: integer
        }
  defstruct [:minimum, :maximum, :minimumUtc, :maximumUtc]

  field :minimum, 1, optional: true, type: :sint64
  field :maximum, 2, optional: true, type: :sint64
  field :minimumUtc, 3, optional: true, type: :sint64
  field :maximumUtc, 4, optional: true, type: :sint64
end

defmodule Orc.Proto.BinaryStatistics do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          sum: integer
        }
  defstruct [:sum]

  field :sum, 1, optional: true, type: :sint64
end

defmodule Orc.Proto.CollectionStatistics do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          minChildren: non_neg_integer,
          maxChildren: non_neg_integer,
          totalChildren: non_neg_integer
        }
  defstruct [:minChildren, :maxChildren, :totalChildren]

  field :minChildren, 1, optional: true, type: :uint64
  field :maxChildren, 2, optional: true, type: :uint64
  field :totalChildren, 3, optional: true, type: :uint64
end

defmodule Orc.Proto.ColumnStatistics do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          numberOfValues: non_neg_integer,
          intStatistics: Orc.Proto.IntegerStatistics.t() | nil,
          doubleStatistics: Orc.Proto.DoubleStatistics.t() | nil,
          stringStatistics: Orc.Proto.StringStatistics.t() | nil,
          bucketStatistics: Orc.Proto.BucketStatistics.t() | nil,
          decimalStatistics: Orc.Proto.DecimalStatistics.t() | nil,
          dateStatistics: Orc.Proto.DateStatistics.t() | nil,
          binaryStatistics: Orc.Proto.BinaryStatistics.t() | nil,
          timestampStatistics: Orc.Proto.TimestampStatistics.t() | nil,
          hasNull: boolean,
          bytesOnDisk: non_neg_integer,
          collectionStatistics: Orc.Proto.CollectionStatistics.t() | nil
        }
  defstruct [
    :numberOfValues,
    :intStatistics,
    :doubleStatistics,
    :stringStatistics,
    :bucketStatistics,
    :decimalStatistics,
    :dateStatistics,
    :binaryStatistics,
    :timestampStatistics,
    :hasNull,
    :bytesOnDisk,
    :collectionStatistics
  ]

  field :numberOfValues, 1, optional: true, type: :uint64
  field :intStatistics, 2, optional: true, type: Orc.Proto.IntegerStatistics
  field :doubleStatistics, 3, optional: true, type: Orc.Proto.DoubleStatistics
  field :stringStatistics, 4, optional: true, type: Orc.Proto.StringStatistics
  field :bucketStatistics, 5, optional: true, type: Orc.Proto.BucketStatistics
  field :decimalStatistics, 6, optional: true, type: Orc.Proto.DecimalStatistics
  field :dateStatistics, 7, optional: true, type: Orc.Proto.DateStatistics
  field :binaryStatistics, 8, optional: true, type: Orc.Proto.BinaryStatistics
  field :timestampStatistics, 9, optional: true, type: Orc.Proto.TimestampStatistics
  field :hasNull, 10, optional: true, type: :bool
  field :bytesOnDisk, 11, optional: true, type: :uint64
  field :collectionStatistics, 12, optional: true, type: Orc.Proto.CollectionStatistics
end

defmodule Orc.Proto.RowIndexEntry do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          positions: [non_neg_integer],
          statistics: Orc.Proto.ColumnStatistics.t() | nil
        }
  defstruct [:positions, :statistics]

  field :positions, 1, repeated: true, type: :uint64, packed: true
  field :statistics, 2, optional: true, type: Orc.Proto.ColumnStatistics
end

defmodule Orc.Proto.RowIndex do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          entry: [Orc.Proto.RowIndexEntry.t()]
        }
  defstruct [:entry]

  field :entry, 1, repeated: true, type: Orc.Proto.RowIndexEntry
end

defmodule Orc.Proto.BloomFilter do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          numHashFunctions: non_neg_integer,
          bitset: [non_neg_integer],
          utf8bitset: binary
        }
  defstruct [:numHashFunctions, :bitset, :utf8bitset]

  field :numHashFunctions, 1, optional: true, type: :uint32
  field :bitset, 2, repeated: true, type: :fixed64
  field :utf8bitset, 3, optional: true, type: :bytes
end

defmodule Orc.Proto.BloomFilterIndex do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          bloomFilter: [Orc.Proto.BloomFilter.t()]
        }
  defstruct [:bloomFilter]

  field :bloomFilter, 1, repeated: true, type: Orc.Proto.BloomFilter
end

defmodule Orc.Proto.Stream do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          kind: Orc.Proto.Stream.Kind.t(),
          column: non_neg_integer,
          length: non_neg_integer
        }
  defstruct [:kind, :column, :length]

  field :kind, 1, optional: true, type: Orc.Proto.Stream.Kind, enum: true
  field :column, 2, optional: true, type: :uint32
  field :length, 3, optional: true, type: :uint64
end

defmodule Orc.Proto.ColumnEncoding do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          kind: Orc.Proto.ColumnEncoding.Kind.t(),
          dictionarySize: non_neg_integer,
          bloomEncoding: non_neg_integer
        }
  defstruct [:kind, :dictionarySize, :bloomEncoding]

  field :kind, 1, optional: true, type: Orc.Proto.ColumnEncoding.Kind, enum: true
  field :dictionarySize, 2, optional: true, type: :uint32
  field :bloomEncoding, 3, optional: true, type: :uint32
end

defmodule Orc.Proto.StripeEncryptionVariant do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          streams: [Orc.Proto.Stream.t()],
          encoding: [Orc.Proto.ColumnEncoding.t()]
        }
  defstruct [:streams, :encoding]

  field :streams, 1, repeated: true, type: Orc.Proto.Stream
  field :encoding, 2, repeated: true, type: Orc.Proto.ColumnEncoding
end

defmodule Orc.Proto.StripeFooter do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          streams: [Orc.Proto.Stream.t()],
          columns: [Orc.Proto.ColumnEncoding.t()],
          writerTimezone: String.t(),
          encryption: [Orc.Proto.StripeEncryptionVariant.t()]
        }
  defstruct [:streams, :columns, :writerTimezone, :encryption]

  field :streams, 1, repeated: true, type: Orc.Proto.Stream
  field :columns, 2, repeated: true, type: Orc.Proto.ColumnEncoding
  field :writerTimezone, 3, optional: true, type: :string
  field :encryption, 4, repeated: true, type: Orc.Proto.StripeEncryptionVariant
end

defmodule Orc.Proto.StringPair do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          key: String.t(),
          value: String.t()
        }
  defstruct [:key, :value]

  field :key, 1, optional: true, type: :string
  field :value, 2, optional: true, type: :string
end

defmodule Orc.Proto.Type do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          kind: Orc.Proto.Type.Kind.t(),
          subtypes: [non_neg_integer],
          fieldNames: [String.t()],
          maximumLength: non_neg_integer,
          precision: non_neg_integer,
          scale: non_neg_integer,
          attributes: [Orc.Proto.StringPair.t()]
        }
  defstruct [:kind, :subtypes, :fieldNames, :maximumLength, :precision, :scale, :attributes]

  field :kind, 1, optional: true, type: Orc.Proto.Type.Kind, enum: true
  field :subtypes, 2, repeated: true, type: :uint32, packed: true
  field :fieldNames, 3, repeated: true, type: :string
  field :maximumLength, 4, optional: true, type: :uint32
  field :precision, 5, optional: true, type: :uint32
  field :scale, 6, optional: true, type: :uint32
  field :attributes, 7, repeated: true, type: Orc.Proto.StringPair
end

defmodule Orc.Proto.StripeInformation do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          offset: non_neg_integer,
          indexLength: non_neg_integer,
          dataLength: non_neg_integer,
          footerLength: non_neg_integer,
          numberOfRows: non_neg_integer,
          encryptStripeId: non_neg_integer,
          encryptedLocalKeys: [binary]
        }
  defstruct [
    :offset,
    :indexLength,
    :dataLength,
    :footerLength,
    :numberOfRows,
    :encryptStripeId,
    :encryptedLocalKeys
  ]

  field :offset, 1, optional: true, type: :uint64
  field :indexLength, 2, optional: true, type: :uint64
  field :dataLength, 3, optional: true, type: :uint64
  field :footerLength, 4, optional: true, type: :uint64
  field :numberOfRows, 5, optional: true, type: :uint64
  field :encryptStripeId, 6, optional: true, type: :uint64
  field :encryptedLocalKeys, 7, repeated: true, type: :bytes
end

defmodule Orc.Proto.UserMetadataItem do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          name: String.t(),
          value: binary
        }
  defstruct [:name, :value]

  field :name, 1, optional: true, type: :string
  field :value, 2, optional: true, type: :bytes
end

defmodule Orc.Proto.StripeStatistics do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          colStats: [Orc.Proto.ColumnStatistics.t()]
        }
  defstruct [:colStats]

  field :colStats, 1, repeated: true, type: Orc.Proto.ColumnStatistics
end

defmodule Orc.Proto.Metadata do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          stripeStats: [Orc.Proto.StripeStatistics.t()]
        }
  defstruct [:stripeStats]

  field :stripeStats, 1, repeated: true, type: Orc.Proto.StripeStatistics
end

defmodule Orc.Proto.ColumnarStripeStatistics do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          colStats: [Orc.Proto.ColumnStatistics.t()]
        }
  defstruct [:colStats]

  field :colStats, 1, repeated: true, type: Orc.Proto.ColumnStatistics
end

defmodule Orc.Proto.FileStatistics do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          column: [Orc.Proto.ColumnStatistics.t()]
        }
  defstruct [:column]

  field :column, 1, repeated: true, type: Orc.Proto.ColumnStatistics
end

defmodule Orc.Proto.DataMask do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          name: String.t(),
          maskParameters: [String.t()],
          columns: [non_neg_integer]
        }
  defstruct [:name, :maskParameters, :columns]

  field :name, 1, optional: true, type: :string
  field :maskParameters, 2, repeated: true, type: :string
  field :columns, 3, repeated: true, type: :uint32, packed: true
end

defmodule Orc.Proto.EncryptionKey do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          keyName: String.t(),
          keyVersion: non_neg_integer,
          algorithm: Orc.Proto.EncryptionAlgorithm.t()
        }
  defstruct [:keyName, :keyVersion, :algorithm]

  field :keyName, 1, optional: true, type: :string
  field :keyVersion, 2, optional: true, type: :uint32
  field :algorithm, 3, optional: true, type: Orc.Proto.EncryptionAlgorithm, enum: true
end

defmodule Orc.Proto.EncryptionVariant do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          root: non_neg_integer,
          key: non_neg_integer,
          encryptedKey: binary,
          stripeStatistics: [Orc.Proto.Stream.t()],
          fileStatistics: binary
        }
  defstruct [:root, :key, :encryptedKey, :stripeStatistics, :fileStatistics]

  field :root, 1, optional: true, type: :uint32
  field :key, 2, optional: true, type: :uint32
  field :encryptedKey, 3, optional: true, type: :bytes
  field :stripeStatistics, 4, repeated: true, type: Orc.Proto.Stream
  field :fileStatistics, 5, optional: true, type: :bytes
end

defmodule Orc.Proto.Encryption do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          mask: [Orc.Proto.DataMask.t()],
          key: [Orc.Proto.EncryptionKey.t()],
          variants: [Orc.Proto.EncryptionVariant.t()],
          keyProvider: Orc.Proto.KeyProviderKind.t()
        }
  defstruct [:mask, :key, :variants, :keyProvider]

  field :mask, 1, repeated: true, type: Orc.Proto.DataMask
  field :key, 2, repeated: true, type: Orc.Proto.EncryptionKey
  field :variants, 3, repeated: true, type: Orc.Proto.EncryptionVariant
  field :keyProvider, 4, optional: true, type: Orc.Proto.KeyProviderKind, enum: true
end

defmodule Orc.Proto.Footer do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          headerLength: non_neg_integer,
          contentLength: non_neg_integer,
          stripes: [Orc.Proto.StripeInformation.t()],
          types: [Orc.Proto.Type.t()],
          metadata: [Orc.Proto.UserMetadataItem.t()],
          numberOfRows: non_neg_integer,
          statistics: [Orc.Proto.ColumnStatistics.t()],
          rowIndexStride: non_neg_integer,
          writer: non_neg_integer,
          encryption: Orc.Proto.Encryption.t() | nil
        }
  defstruct [
    :headerLength,
    :contentLength,
    :stripes,
    :types,
    :metadata,
    :numberOfRows,
    :statistics,
    :rowIndexStride,
    :writer,
    :encryption
  ]

  field :headerLength, 1, optional: true, type: :uint64
  field :contentLength, 2, optional: true, type: :uint64
  field :stripes, 3, repeated: true, type: Orc.Proto.StripeInformation
  field :types, 4, repeated: true, type: Orc.Proto.Type
  field :metadata, 5, repeated: true, type: Orc.Proto.UserMetadataItem
  field :numberOfRows, 6, optional: true, type: :uint64
  field :statistics, 7, repeated: true, type: Orc.Proto.ColumnStatistics
  field :rowIndexStride, 8, optional: true, type: :uint32
  field :writer, 9, optional: true, type: :uint32
  field :encryption, 10, optional: true, type: Orc.Proto.Encryption
end

defmodule Orc.Proto.PostScript do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          footerLength: non_neg_integer,
          compression: Orc.Proto.CompressionKind.t(),
          compressionBlockSize: non_neg_integer,
          version: [non_neg_integer],
          metadataLength: non_neg_integer,
          writerVersion: non_neg_integer,
          stripeStatisticsLength: non_neg_integer,
          magic: String.t()
        }
  defstruct [
    :footerLength,
    :compression,
    :compressionBlockSize,
    :version,
    :metadataLength,
    :writerVersion,
    :stripeStatisticsLength,
    :magic
  ]

  field :footerLength, 1, optional: true, type: :uint64
  field :compression, 2, optional: true, type: Orc.Proto.CompressionKind, enum: true
  field :compressionBlockSize, 3, optional: true, type: :uint64
  field :version, 4, repeated: true, type: :uint32, packed: true
  field :metadataLength, 5, optional: true, type: :uint64
  field :writerVersion, 6, optional: true, type: :uint32
  field :stripeStatisticsLength, 7, optional: true, type: :uint64
  field :magic, 8000, optional: true, type: :string
end

defmodule Orc.Proto.FileTail do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          postscript: Orc.Proto.PostScript.t() | nil,
          footer: Orc.Proto.Footer.t() | nil,
          fileLength: non_neg_integer,
          postscriptLength: non_neg_integer
        }
  defstruct [:postscript, :footer, :fileLength, :postscriptLength]

  field :postscript, 1, optional: true, type: Orc.Proto.PostScript
  field :footer, 2, optional: true, type: Orc.Proto.Footer
  field :fileLength, 3, optional: true, type: :uint64
  field :postscriptLength, 4, optional: true, type: :uint64
end
