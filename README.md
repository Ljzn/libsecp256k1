# Erlang NIF C libsecp256k1

============

Installation
------------
If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `libsecp256k1` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:libsecp256k1, github: "ljzn/libsecp256k1", tag: "v0.2.2"}
  ]
end
```

Available Functions
-------

```
ec_pubkey_create/2
ec_pubkey_decompress/1
ec_pubkey_verify/1
ec_privkey_export/2
ec_privkey_import/1
ec_privkey_tweak_add/2
ec_privkey_tweak_mul/2
ec_pubkey_tweak_add/2
ec_pubkey_tweak_mul/2
ecdsa_sign/4
ecdsa_verify/3
schnorr_sign/2
schnorr_verify/3
ecdsa_sign_compact/4
ecdsa_recover_compact/4
ecdsa_verify_compact/3
sha256/1
dsha256/1
ec_xonly_pubkey_tweak_add/2
```

Testing
-------
  $ mix test
