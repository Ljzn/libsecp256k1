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

  test "schnorr sign" do
    for _ <- 0..10 do
      {prv, xonly_pub} = generate_valid_schnorr_keypair()
      msg = :crypto.strong_rand_bytes(32)
      {:ok, signature} = :libsecp256k1.schnorr_sign(msg, prv)

      assert :ok == :libsecp256k1.schnorr_verify(msg, signature, xonly_pub)
    end
  end

  defp generate_valid_schnorr_keypair() do
    prv = :crypto.strong_rand_bytes(32)
    {:ok, pub} = :libsecp256k1.ec_pubkey_create(prv, :uncompressed)
    <<_::8, xonly_pub::32-bytes, y::256>> = pub

    if rem(y, 2) == 0 do
      # y must be even
      {prv, xonly_pub}
    else
      generate_valid_schnorr_keypair()
    end
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

  test "ec_privkey_tweak_add" do
    prv = <<0x6B973D88838F27366ED61C9AD6367663045CB456E28335C109E30717AE0C6BAA::256>>
    tweak = <<0xB86E7BE8F39BAB32A6F2C0443ABBC210F0EDAC0E2C53D501B36B64437D9C6C70::256>>
    tweaked_prv = <<0x2405B971772AD26915C8DCDF10F238753A9B837E5F8E6A86FD7C0CCE5B7296D9::256>>

    assert {:ok, tweaked_prv} == :libsecp256k1.ec_privkey_tweak_add(prv, tweak)
  end
end
