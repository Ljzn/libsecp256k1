defmodule Libsecp256k1Test do
  use ExUnit.Case

  test "create_keys" do
    a = :crypto.strong_rand_bytes(32)
    {:ok, b} = :libsecp256k1.ec_pubkey_create(a, :compressed)
    {:ok, b2} = :libsecp256k1.ec_pubkey_create(a, :uncompressed)
    {:ok, c} = :libsecp256k1.ec_pubkey_decompress(b)
    assert b2 == c
    assert :ok == :libsecp256k1.ec_pubkey_verify(b)
    assert :ok == :libsecp256k1.ec_pubkey_verify(c)
  end

  test "invalid_keys" do
    a = :crypto.strong_rand_bytes(16)
    assert {:error, _Msg} = :libsecp256k1.ec_pubkey_create(a, :compressed)
    assert {:error, _Msg} = :libsecp256k1.ec_pubkey_create(a, :invalidflag)
  end

  test "import_export" do
    a = :crypto.strong_rand_bytes(32)
    {:ok, b} = :libsecp256k1.ec_privkey_export(a, :compressed)
    {:ok, c} = :libsecp256k1.ec_privkey_import(b)
    assert a == c
  end

  test "tweaks" do
    <<a::256-bitstring, tweak::256-bitstring>> = :crypto.strong_rand_bytes(64)
    {:ok, pubkey} = :libsecp256k1.ec_pubkey_create(a, :compressed)
    {:ok, a2} = :libsecp256k1.ec_privkey_tweak_add(a, tweak)
    {:ok, a3} = :libsecp256k1.ec_privkey_tweak_mul(a, tweak)
    {:ok, pubkey2} = :libsecp256k1.ec_pubkey_tweak_add(pubkey, tweak)
    {:ok, pubkey3} = :libsecp256k1.ec_pubkey_tweak_mul(pubkey, tweak)
    {:ok, pubkey_a2} = :libsecp256k1.ec_pubkey_create(a2, :compressed)
    {:ok, pubkey_a3} = :libsecp256k1.ec_pubkey_create(a3, :compressed)
    assert pubkey2 == pubkey_a2
    assert pubkey3 == pubkey_a3
  end

  test "signing" do
    msg = "This is a secret message..."
    a = :crypto.strong_rand_bytes(32)
    {:ok, pubkey} = :libsecp256k1.ec_pubkey_create(a, :compressed)
    {:ok, signature} = :libsecp256k1.ecdsa_sign(msg, a, :default, <<>>)
    assert :ok == :libsecp256k1.ecdsa_verify(msg, signature, pubkey)
  end

  test "blank_msg" do
    msg = <<>>
    a = :crypto.strong_rand_bytes(32)
    {:ok, pubkey} = :libsecp256k1.ec_pubkey_create(a, :compressed)
    {:ok, signature} = :libsecp256k1.ecdsa_sign(msg, a, :default, <<>>)
    assert :ok == :libsecp256k1.ecdsa_verify(msg, signature, pubkey)
  end

  test "compact_signing" do
    msg = "This is a very secret compact message..."
    a = :crypto.strong_rand_bytes(32)
    {:ok, pubkey} = :libsecp256k1.ec_pubkey_create(a, :uncompressed)
    {:ok, signature, recovery_id} = :libsecp256k1.ecdsa_sign_compact(msg, a, :default, <<>>)

    {:ok, recovered_key} =
      :libsecp256k1.ecdsa_recover_compact(msg, signature, :uncompressed, recovery_id)

    assert pubkey == recovered_key
    assert :ok == :libsecp256k1.ecdsa_verify_compact(msg, signature, pubkey)
  end

  test "sha256" do
    a = :crypto.strong_rand_bytes(64)
    double_hashed = :crypto.hash(:sha256, :crypto.hash(:sha256, a))
    assert double_hashed == :libsecp256k1.sha256(:libsecp256k1.sha256(a))
    assert double_hashed == :libsecp256k1.dsha256(a)
  end

  test "ec_xonly_pubkey_tweak_add" do
    internal_pubkey = <<0xCC8A4BC64D897BDDC5FBC2F670F7A8BA0B386779106CF1223C6FC5D7CD6FC115::256>>
    tweak = <<0x2CA01ED85CF6B6526F73D39A1111CD80333BFDC00CE98992859848A90A6F0258::256>>
    tweaked_key = <<0xA60869F0DBCF1DC659C9CECBAF8050135EA9E8CDC487053F1DC6880949DC684C::256>>

    assert {:ok, <<_::8, ^tweaked_key::bytes-32, _y::256>>} =
             :libsecp256k1.ec_xonly_pubkey_tweak_add(internal_pubkey, tweak)
  end
end
